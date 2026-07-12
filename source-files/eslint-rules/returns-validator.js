// @ts-check
const REGISTRARS = new Set(['query','mutation','action','internalQuery','internalMutation','internalAction'])
const isVCall = (n, name) =>
  n && n.type === 'CallExpression' && n.callee.type === 'MemberExpression' &&
  n.callee.object.type === 'Identifier' && n.callee.object.name === 'v' &&
  !n.callee.computed && n.callee.property.type === 'Identifier' && n.callee.property.name === name
const isVAny = (n) => isVCall(n, 'any')
const isVObject = (n) => isVCall(n, 'object')
/** First `v.any()` NOT enclosed by a `v.object({...})` property value, else null.
 * NOTE (PM2): once inside ANY v.object property value, all descendant v.any() is
 * allowed — deep misuse (v.object({filters:v.array(v.any())})) is caught by the
 * Task 6 nested-audit + manifest, not this rule. */
const findTopLevelAny = (root, sc) => {
  let found = null
  const walk = (n, inside) => {
    if (found || !n || typeof n.type !== 'string') return
    if (isVAny(n)) { if (!inside) found = n; return }
    if (isVObject(n)) {
      const arg = n.arguments[0]
      if (arg && arg.type === 'ObjectExpression') for (const p of arg.properties) {
        if (p.type === 'Property') walk(p.value, true)
        else if (p.type === 'SpreadElement') walk(p.argument, inside)
      }
      return
    }
    for (const key of sc.visitorKeys[n.type] ?? []) {
      const c = n[key]; if (Array.isArray(c)) c.forEach((x) => walk(x, inside)); else walk(c, inside)
    }
  }
  walk(root, false); return found
}
/** @type {import('eslint').Rule.RuleModule} */
export default {
  meta: {
    type: 'problem',
    docs: { description: 'Every exported Convex registrar function must declare a specific `returns` validator (no top-level v.any()). Only the inline `export const f = <registrar>({...})` form is detected; Task 6 `convex function-spec` proves no real function uses an uncovered form.' },
    schema: [{ type: 'object', properties: { allowlist: { type: 'array', items: { type: 'string' } } }, additionalProperties: false }],
    messages: {
      'missing-returns': 'Convex function is missing a `returns` validator.',
      'any-in-returns': '`returns` is (or top-level-wraps) v.any() — declare a specific return shape. Nested v.any() is allowed only inside a v.object property to mirror a schema v.any() field.',
    },
  },
  create(context) {
    const allowlist = new Set(context.options[0]?.allowlist ?? [])
    const sc = context.sourceCode ?? context.getSourceCode()
    const base = (context.filename ?? context.getFilename()).split('/').pop().replace(/\.ts$/, '')
    return {
      VariableDeclarator(node) {
        const parentDecl = node.parent, exportDecl = parentDecl?.parent
        if (exportDecl?.type !== 'ExportNamedDeclaration' && parentDecl?.parent?.parent?.type !== 'ExportNamedDeclaration') return
        const init = node.init
        if (!(init?.type === 'CallExpression' && init.callee.type === 'Identifier' && REGISTRARS.has(init.callee.name) && init.arguments.length === 1)) return
        const cfg = init.arguments[0]
        if (cfg.type !== 'ObjectExpression') return
        const name = node.id.type === 'Identifier' ? node.id.name : null
        const returnsProp = cfg.properties.find((p) => p.type === 'Property' && p.key.type === 'Identifier' && p.key.name === 'returns')
        if (!returnsProp) { if (!(name && allowlist.has(`${base}.${name}`))) context.report({ node: cfg, messageId: 'missing-returns' }); return }
        const any = findTopLevelAny(returnsProp.value, sc)
        if (any) context.report({ node: any, messageId: 'any-in-returns' })
      },
    }
  },
}
