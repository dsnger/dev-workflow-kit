import { RuleTester } from 'eslint'
import { describe, it } from 'vitest'
import rule from './returns-validator.js'

RuleTester.describe = describe
RuleTester.it = it

const tester = new RuleTester({ languageOptions: { ecmaVersion: 2022, sourceType: 'module' } })

tester.run('returns-validator', rule, {
  valid: [
    { code: `export const f = query({ args: {}, returns: v.id('cards'), handler: async () => x })` },
    { code: `export const f = mutation({ args: {}, returns: v.null(), handler: async () => {} })` },
    { code: `export const f = query({ args: {}, returns: v.object({ filters: v.any() }), handler: async () => x })` },
    { code: `export const f = query({ args: {}, returns: v.optional(v.object({ settings: v.any() })), handler: async () => x })` },
    // deep-nested v.any() the rule ALLOWS by design (Task 6 nested-audit catches misuse):
    { code: `export const f = query({ args: {}, returns: v.object({ filters: v.array(v.any()) }), handler: async () => x })` },
    { code: `export const f = query({ args: {}, returns: v.object({ filters: v.optional(v.any()) }), handler: async () => x })` },
    { code: `export const f = internalMutation({ args: {}, returns: v.null(), handler: async () => {} })` },
    { code: `export const f = somethingElse({ handler: async () => {} })` },
    { code: `const f = query({ args: {}, handler: async () => x })` },
    // export-form pin (PM1): indirect `export { f }` re-export is NOT covered by
    // this rule (only the inline `export const f = <registrar>({...})` form is
    // detected) — Task 6's `convex function-spec` guarantees no real function
    // uses this uncovered form.
    { code: `const f = query({ args: {}, handler: async () => x }); export { f }` },
    { code: `export const me = query({ args: {}, handler: async () => x })`, options: [{ allowlist: ['test.me'] }], filename: 'test.ts' },
  ],
  invalid: [
    { code: `export const f = query({ args: {}, handler: async () => x })`, errors: [{ messageId: 'missing-returns' }] },
    { code: `export const f = query({ args: {}, returns: v.any(), handler: async () => x })`, errors: [{ messageId: 'any-in-returns' }] },
    { code: `export const f = query({ args: {}, returns: v.optional(v.any()), handler: async () => x })`, errors: [{ messageId: 'any-in-returns' }] },
    { code: `export const f = query({ args: {}, returns: v.union(v.any(), v.null()), handler: async () => x })`, errors: [{ messageId: 'any-in-returns' }] },
    { code: `export const f = query({ args: {}, returns: v.array(v.any()), handler: async () => x })`, errors: [{ messageId: 'any-in-returns' }] },
    { code: `export const f = query({ args: {}, returns: v.record(v.string(), v.any()), handler: async () => x })`, errors: [{ messageId: 'any-in-returns' }] },
    { code: `export const f = internalMutation({ args: {}, handler: async () => {} })`, errors: [{ messageId: 'missing-returns' }] },
  ],
})
