import { RuleTester } from 'eslint'
import { describe, it } from 'vitest'
import rule from './auth-before-db.js'

RuleTester.describe = describe
RuleTester.it = it

const tester = new RuleTester({ languageOptions: { ecmaVersion: 2022, sourceType: 'module' } })

tester.run('auth-before-db', rule, {
  valid: [
    // primitive barrier before read
    { code: `export const f = mutation({ handler: async (ctx, args) => { await requireAuth(ctx); const c = await ctx.db.get('cards', args.id); return c } })` },
    // helper barrier before read
    { code: `export const f = mutation({ handler: async (ctx, args) => { await requireCardEditContext(ctx, args.cardId); await ctx.db.patch('cards', args.cardId, {}) } })` },
    // const-destructured barrier
    { code: `export const f = query({ handler: async (ctx, args) => { const { userId } = await requireRole(ctx, args.ws, []); const c = await ctx.db.get('cards', args.id); return c } })` },
    // pure computation before barrier is fine
    { code: `export const f = mutation({ handler: async (ctx, args) => { const n = args.ids.length; await requireAuth(ctx); await ctx.db.query('cards') } })` },
    // internal* is out of scope
    { code: `export const f = internalMutation({ handler: async (ctx, args) => { const c = await ctx.db.get('cards', args.id) } })` },
    // allowlisted handler (users.me) — configured via options
    { code: `export const me = query({ handler: async (ctx) => { const id = await getAuthUserId(ctx); if (id === null) return null; return await ctx.db.get('users', id) } })`,
      options: [{ allowlist: ['test.me'] }], filename: 'test.ts' },
    // mixed-declaration the other way (auth declarator first is clean)
    { code: `export const f = query({ handler: async (ctx, args) => { const { userId } = await requireRole(ctx, args.ws, []), c = await ctx.db.get('cards', args.id); return c } })` },
    // a ctx-passing helper AFTER the barrier is fine
    { code: `export const f = mutation({ handler: async (ctx, args) => { await requireAuth(ctx); await loadThing(ctx, args.id); await ctx.db.patch('cards', args.id, {}) } })` },
    // a pre-auth call that does NOT pass ctx is fine (pure computation)
    { code: `export const f = query({ handler: async (ctx, args) => { const n = compute(args.x); await requireRole(ctx, args.ws, []); return n } })` },
    // auth barrier before a ctx-passing helper in the SAME declaration is clean (auth ends first)
    { code: `export const f = query({ handler: async (ctx, args) => { const x = await requireRole(ctx, args.ws, []), c = await loadThing(ctx, args.id); return c } })` },
    // a namespaced ctx-passing helper AFTER the barrier is clean
    { code: `export const f = mutation({ handler: async (ctx, args) => { await requireAuth(ctx); await helpers.loadThing(ctx, args.id); await ctx.db.patch('cards', args.id, {}) } })` },
  ],
  invalid: [
    // db read before any barrier
    { code: `export const f = query({ handler: async (ctx, args) => { const c = await ctx.db.get('cards', args.id); await requireAuth(ctx); return c } })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // NESTED return before barrier (the silent-no-op shape)
    { code: `export const f = mutation({ handler: async (ctx, args) => { if (args.ids.length === 0) return; await requireRole(ctx, args.ws, []) } })`,
      errors: [{ messageId: 'returnBeforeAuth' }] },
    // auth nested in a conditional does NOT count as barrier → fallthrough
    { code: `export const f = mutation({ handler: async (ctx, args) => { if (args.ids.length > 0) { await requireAuth(ctx) } await ctx.db.query('cards') } })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // getAuthUserId is NOT a barrier — and as a ctx-passing non-auth call before auth
    // it trips the helper guard first (still flags the handler; users.me is allowlisted).
    { code: `export const f = query({ handler: async (ctx, args) => { const id = await getAuthUserId(ctx); const c = await ctx.db.get('users', id); return c } })`,
      errors: [{ messageId: 'ctxBeforeAuth' }] },
    // assertActiveMembership is NOT a barrier (validates an arbitrary userId, not the caller);
    // as a ctx-passing non-auth call before auth it trips the helper guard.
    { code: `export const f = mutation({ handler: async (ctx, args) => { await assertActiveMembership(ctx, args.ws, args.u, 'x'); await ctx.db.query('cards') } })`,
      errors: [{ messageId: 'ctxBeforeAuth' }] },
    // MIXED declaration: db read shares a statement with the auth declarator but precedes it → flagged
    { code: `export const f = query({ handler: async (ctx, args) => { const c = await ctx.db.get('cards', args.id), { userId } = await requireRole(ctx, args.ws, []); return c } })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // EXPRESSION-BODIED handler with a pre-auth read
    { code: `export const f = query({ handler: async (ctx) => await ctx.db.query('cards') })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // nested auth in an if-branch must not mask an unauthenticated read in the else-branch
    { code: `export const f = mutation({ handler: async (ctx, args) => { if (args.ok) { await requireAuth(ctx) } else { await ctx.db.get('cards', args.id) } } })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // nested auth followed by a nested read in the SAME block is still not a top-level barrier
    { code: `export const f = mutation({ handler: async (ctx, args) => { if (args.ok) { await requireAuth(ctx); await ctx.db.get('cards', args.id) } } })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // nested auth followed by a nested return in the SAME block is still not a top-level barrier
    { code: `export const f = mutation({ handler: async (ctx, args) => { if (args.ok) { await requireAuth(ctx); return null } } })`,
      errors: [{ messageId: 'returnBeforeAuth' }] },
    // UN-AWAITED auth is not a barrier: the promise hasn't resolved before the read
    { code: `export const f = query({ handler: async (ctx, args) => { const p = requireAuth(ctx); const c = await ctx.db.get('cards', args.id); await p; return c } })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // ctx passed to a non-auth helper BEFORE auth (helper-extracted lookup oracle)
    { code: `export const f = query({ handler: async (ctx, args) => { const c = await loadThing(ctx, args.id); await requireAuth(ctx); return c } })`,
      errors: [{ messageId: 'ctxBeforeAuth' }] },
    // a db read INSIDE an auth call's arguments evaluates before auth → flagged
    { code: `export const f = query({ handler: async (ctx, args) => { const m = await requireRole(ctx, (await ctx.db.get('workspaces', args.id)).x, []); return m } })`,
      errors: [{ messageId: 'readBeforeAuth' }] },
    // ctx passed via an object literal to a helper before auth → flagged
    { code: `export const f = query({ handler: async (ctx, args) => { const c = await loadThing({ ctx, id: args.id }); await requireAuth(ctx); return c } })`,
      errors: [{ messageId: 'ctxBeforeAuth' }] },
    // helper before auth in ONE declaration (helper starts before the auth call ends)
    { code: `export const f = query({ handler: async (ctx, args) => { const c = await loadThing(ctx, args.id), x = await requireAuth(ctx); return c } })`,
      errors: [{ messageId: 'ctxBeforeAuth' }] },
    // NAMESPACED (member-expression) ctx-passing helper before auth → flagged
    { code: `export const f = query({ handler: async (ctx, args) => { const c = await helpers.loadThing(ctx, args.id); await requireAuth(ctx); return c } })`,
      errors: [{ messageId: 'ctxBeforeAuth' }] },
    // deep member callee + ctx nested in an object before auth → flagged
    { code: `export const f = mutation({ handler: async (ctx, args) => { await services.cards.load({ ctx, id: args.id }); await requireAuth(ctx) } })`,
      errors: [{ messageId: 'ctxBeforeAuth' }] },
  ],
})
