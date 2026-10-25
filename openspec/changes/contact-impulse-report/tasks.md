# Tasks

## 1. Test

- [ ] 1.1 Test: a two-point contact reduced to one point by the block solver reports `count` = 2 and 0 for the second point, after another contact left a non-zero second impulse in the shared report; fails before the change

## 2. Report

- [ ] 2.1 `B2ContactImpulse.count`
- [ ] 2.2 `B2Island.report` fills every manifold point (0 for a dropped one) and sets `count`
- [ ] 2.3 `B2ContactSolver.finalizeVelocityConstraints` stores 0 for a dropped manifold point

## 3. Checks

- [ ] 3.1 `bash test/run.sh` passes; every module types on `--interp`, `-hl`, `-js`
