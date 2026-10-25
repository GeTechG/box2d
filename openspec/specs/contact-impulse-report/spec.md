# contact-impulse-report Specification

## Purpose
What `B2ContactListener.postSolve` reports for each point of a contact's manifold.

## Requirements

### Requirement: postSolve reports one impulse per manifold point
The `B2ContactImpulse` passed to `B2ContactListener.postSolve` SHALL hold, in `count`, the point count of the contact's manifold, and in `normalImpulses[i]` / `tangentImpulses[i]` for every `i < count` the impulse the solver applied at manifold point `i` in that solve. A manifold point the solver did not use (the block solver keeps one point of a badly conditioned two-point manifold) SHALL report 0 and SHALL keep 0 as its cached impulse for warm starting.

#### Scenario: Two-point manifold solved with one point
- **WHEN** a contact has a two-point manifold whose block-solver matrix is badly conditioned, and the report of another contact before it had a non-zero second impulse
- **THEN** its `postSolve` receives `count` = 2 and 0 as the normal and tangent impulse of the second point, and the second manifold point caches impulse 0
