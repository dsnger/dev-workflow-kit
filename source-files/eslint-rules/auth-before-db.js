// @ts-check
// Step 6 grounded-decision record (harden/lookup-before-auth-class, Task 1):
// - `assertCanDelete` is intentionally NOT in RECOGNIZED. `grep -rn "assertCanDelete" convex/`
//   shows its only callers are `media.remove` / `media.bulkDelete`, both of which read `media`
//   BEFORE calling assertCanDelete — i.e. they are PATTERN-P handlers already flagged by this
//   rule via the earlier read, independent of whether assertCanDelete is recognized. So there
//   is no clean handler relying on assertCanDelete as its first barrier, and no collision
//   surface from omitting it.
// - Barrier-name uniqueness: for each of requireCardEditContext, requireCardReadable,
//   requireReadableCardContext, requireReadableConversationContext,
//   `grep -rln "function $n\|const $n" convex/` returns exactly one file — no cross-file
//   same-name collisions among the recognized helpers.
//
// Known scope limits (surfaced by Gate B review, deliberately not addressed here):
// - A `return`/`ctx.db` call inside a nested function/closure declared in the handler
//   body (e.g. a local helper defined before the auth barrier) is attributed to the
//   handler's own control flow, since the AST walk does not special-case nested
//   FunctionDeclaration/FunctionExpression/ArrowFunctionExpression scopes. This can
//   only produce a false positive (over-flagging), never a missed lookup-before-auth
//   case. Task 1 does not touch convex/*.ts handlers, so no codebase search for this
//   pattern was performed; left as spec-matching behavior — revisit before Task Q if
//   it fires against a real handler.
// - An expression-bodied handler with an implicit return that touches neither auth nor
//   `ctx.db` (e.g. `handler: async (ctx) => null`) produces no candidate node and is not
//   flagged, since the rule only models explicit `ReturnStatement` nodes. This is not a
//   lookup-before-auth risk (no db access, no early-exit skipping later logic) so it is
//   out of this rule's scope by design.
// - DB_METHODS below is intentionally the brief's exact 6-method list (get/query/insert/
//   patch/replace/delete), not full `ctx.db.*` coverage (e.g. `ctx.db.normalizeId`, which
//   isn't a read, or `ctx.db.system.query`, a distinct 3-level-nested API) — matching the
//   task brief's reference implementation verbatim rather than expanding scope.
const RECOGNIZED = new Set(['requireAuth','requireMembership','requireRole','requireAdminRole','requirePlanner',
  'requireCardEditContext','requireCardReadable','requireReadableCardContext','requireReadableConversationContext'])
const DB_METHODS = new Set(['get','query','insert','patch','replace','delete'])
const HANDLER_KINDS = new Set(['mutation','query','action'])

/** name of an AWAITED recognized auth call; else null. The await is required:
 * a barrier only clears the handler once auth has completed, so a bare
 * `requireAuth(ctx)` (promise not yet resolved) does NOT count — otherwise
 * `const p = requireAuth(ctx); await ctx.db.get(...); await p` would pass while
 * reading before auth resolves. (A bare non-awaited call is itself a floating
 * promise caught by @typescript-eslint/no-floating-promises.) */
const authName = (node) => {
  if (!node || node.type !== 'AwaitExpression') return null
  const n = node.argument
  return n && n.type === 'CallExpression' && n.callee.type === 'Identifier' && RECOGNIZED.has(n.callee.name)
    ? n.callee.name : null
}
const isDbCall = (n, ctxName) =>
  n.type === 'CallExpression' && n.callee.type === 'MemberExpression' &&
  n.callee.object.type === 'MemberExpression' &&
  n.callee.object.object.type === 'Identifier' && n.callee.object.object.name === ctxName &&
  n.callee.object.property.type === 'Identifier' && n.callee.object.property.name === 'db' &&
  n.callee.property.type === 'Identifier' && DB_METHODS.has(n.callee.property.name)

/** Does an expression reference the ctx identifier — directly or nested inside an
 * object/array/spread arg (`{ ctx }`, `[ctx]`, `...[ctx]`) — so a helper receiving
 * it could reach ctx.db? Ignores non-computed member/property KEYS (`foo.ctx`,
 * `{ ctx: x }`) which merely reuse the name. Note: ctx passed via a renamed alias
 * (`const c = ctx; helper(c)`) is NOT tracked — that dataflow residual is the
 * syntactic rule's ceiling (see the class spec §5). */
const refsCtx = (node, ctxName, sc) => {
  let found = false
  const walk = (n) => {
    if (found || !n || typeof n.type !== 'string') return
    if (n.type === 'Identifier') { if (n.name === ctxName) found = true; return }
    for (const key of sc.visitorKeys[n.type] ?? []) {
      if (n.type === 'MemberExpression' && key === 'property' && !n.computed) continue
      if (n.type === 'Property' && key === 'key' && !n.computed) continue
      const c = n[key]
      if (Array.isArray(c)) c.forEach(walk); else walk(c)
    }
  }
  walk(node)
  return found
}

/** @type {import('eslint').Rule.RuleModule} */
export default {
  meta: {
    type: 'problem',
    docs: { description: 'A public Convex handler must authenticate the caller before any ctx.db access or return.' },
    schema: [{ type: 'object', properties: { allowlist: { type: 'array', items: { type: 'string' } } }, additionalProperties: false }],
    messages: {
      readBeforeAuth: 'ctx.db access before the first auth barrier in a public handler (lookup-before-auth).',
      returnBeforeAuth: 'return before the first auth barrier in a public handler (auth-free silent no-op).',
      ctxBeforeAuth: 'ctx passed to a non-auth helper before the first auth barrier in a public handler — the helper could read ctx.db before auth (lookup-before-auth via helper). Authenticate first, or make the call a recognized auth barrier.',
    },
  },
  create(context) {
    const allowlist = new Set(context.options[0]?.allowlist ?? [])
    const sc = context.sourceCode ?? context.getSourceCode()
    const base = (context.filename ?? context.getFilename()).split('/').pop().replace(/\.ts$/, '')
    return {
      CallExpression(node) {
        if (node.callee.type !== 'Identifier' || !HANDLER_KINDS.has(node.callee.name)) return
        const cfg = node.arguments[0]
        if (!cfg || cfg.type !== 'ObjectExpression') return
        const hp = cfg.properties.find((p) => p.type === 'Property' && p.key.type === 'Identifier' && p.key.name === 'handler')
        if (!hp) return
        const fn = hp.value
        if (fn.type !== 'ArrowFunctionExpression' && fn.type !== 'FunctionExpression') return
        const decl = node.parent
        const cname = decl && decl.type === 'VariableDeclarator' && decl.id.type === 'Identifier' ? decl.id.name : null
        if (cname && allowlist.has(`${base}.${cname}`)) return
        const ctxName = fn.params[0] && fn.params[0].type === 'Identifier' ? fn.params[0].name : 'ctx'
        const stmts = fn.body.type === 'BlockStatement' ? fn.body.body : [fn.body]
        for (const stmt of stmts) {
          const cands = []
          const visit = (n) => {
            if (!n || typeof n.type !== 'string') return
            if (n.type === 'ReturnStatement') cands.push({ n, kind: 'return' })
            else if (isDbCall(n, ctxName)) cands.push({ n, kind: 'db' })
            else if (authName(n)) cands.push({ n, kind: 'auth' })
            // A call that PASSES ctx to a non-recognized (non-auth) callee could read
            // ctx.db inside that helper before auth — closing the helper-extracted
            // lookup-before-auth escape hatch (`await loadThing(ctx, id)` or a
            // namespaced `await helpers.loadThing(ctx, id)` before requireAuth). Only a
            // recognized-barrier *identifier* callee is excluded; ctx.db.* is already
            // caught by isDbCall above (else-if precedence).
            else if (n.type === 'CallExpression' &&
              !(n.callee.type === 'Identifier' && RECOGNIZED.has(n.callee.name)) &&
              n.arguments.some((a) => refsCtx(a, ctxName, sc)))
              cands.push({ n, kind: 'helper' })
            for (const key of sc.visitorKeys[n.type] ?? []) {
              const child = n[key]
              if (Array.isArray(child)) child.forEach(visit); else visit(child)
            }
          }
          visit(stmt)
          if (cands.length === 0) continue
          // Sort by runtime evaluation order. A db/helper/return uses its START; an
          // auth barrier uses its END, because a call's ARGUMENTS evaluate before the
          // call runs — so `await requireRole(ctx, await ctx.db.get(…), [])` correctly
          // sorts the inner read BEFORE the auth barrier (the read happens pre-auth).
          const posOf = (c) => (c.kind === 'auth' ? c.n.range[1] : c.n.range[0])
          cands.sort((a, b) => posOf(a) - posOf(b))
          // A statement clears the handler only if its TOP-LEVEL form is itself the
          // auth barrier (bare `await requireX(…)`, a VariableDeclaration with a
          // recognized-auth declarator, or the whole expression-bodied handler) —
          // this is a structural property of the statement, independent of which
          // specific candidate node triggered the match.
          const topLevelBarrier =
            (stmt.type === 'ExpressionStatement' && authName(stmt.expression) !== null) ||
            (stmt.type === 'VariableDeclaration' && stmt.declarations.some((d) => authName(d.init) !== null)) ||
            (stmt === fn.body && authName(stmt) !== null)
          // Walk every candidate in source order. db/return report immediately.
          // A non-top-level (nested, e.g. inside an if/loop/else) auth call is NOT
          // a barrier and does NOT stop the scan — keep checking this statement's
          // remaining candidates. This matters for shapes like
          // `if (c) { requireAuth } else { ctx.db... }`, where a nested auth in one
          // branch must not mask an unauthenticated read reachable via another.
          let barrierHit = false
          for (const cand of cands) {
            if (cand.kind === 'db') { context.report({ node: cand.n, messageId: 'readBeforeAuth' }); return }
            if (cand.kind === 'return') { context.report({ node: cand.n, messageId: 'returnBeforeAuth' }); return }
            if (cand.kind === 'helper') { context.report({ node: cand.n, messageId: 'ctxBeforeAuth' }); return }
            // cand.kind === 'auth'
            if (topLevelBarrier) { barrierHit = true; break }
            // nested auth — not a barrier; keep scanning this statement's remaining candidates
          }
          if (barrierHit) return // authed — clean
          // no db/return found and no barrier in this statement; keep scanning later statements
        }
      },
    }
  },
}
