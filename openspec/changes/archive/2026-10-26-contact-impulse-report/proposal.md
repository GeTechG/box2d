# Proposal

## Why

When the block solver finds the `K` matrix of a two-point manifold badly conditioned, `B2ContactSolver.initialize` solves the contact with one point (`cc.pointCount = 1`). The manifold still has two points, but `B2Island.report` fills only the first entry of the shared static `B2ContactImpulse`, so a listener that reads impulses by `contact.getManifold().m_pointCount` gets a stale second impulse, left over from another contact or an earlier step. `finalizeVelocityConstraints` likewise leaves the second manifold point's cached impulse untouched, and that stale value warm-starts the point once the contact is solved with two points again.

## What Changes

- `B2Island.report` fills one impulse per manifold point; a point the solver dropped reports 0.
- `B2ContactImpulse` gets `count`, the number of valid entries (the manifold's point count).
- `finalizeVelocityConstraints` stores 0 as the cached impulse of a dropped manifold point.

## Capabilities

### New Capabilities
- `contact-impulse-report`: what `postSolve` reports for each point of a contact's manifold.

### Modified Capabilities

## Impact

`box2D/dynamics/B2Island.hx`, `B2ContactImpulse.hx`, `contacts/B2ContactSolver.hx`; a test in `test/`. Additive API; contacts solved with all their points report and cache the same numbers as before.
