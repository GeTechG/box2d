# Tasks

## 1. Test harness

- [x] 1.1 `test/TestMain.hx` with minimal assertions and `test/run.sh` running it on `--interp` with the pinned compiler
- [x] 1.2 Test: one-sided contact (scale A = 0) leaves A's velocity unchanged and bounces B as off a wall; fails before the change
- [x] 1.3 Test: no scales set gives the same result as scales (1, 1); both scales 0 give no NaN and report no cached impulse; a two-point (block solver) one-sided contact; scales are reset before the next `preSolve`

## 2. Contact scales

- [x] 2.1 `B2Contact`: `m_invMassScaleA` / `m_invMassScaleB`, `setInvMassScales`, `getInvMassScaleA`, `getInvMassScaleB`; reset to 1 in `reset` and in `update` before `preSolve`
- [x] 2.2 `B2ContactConstraint`: the contact's `invMassScaleA` / `invMassScaleB`, copied by `initialize`
- [x] 2.3 `B2ContactSolver`: initialize (`kNormal`, `kEqualized`, `kTangent`, block `K`), warm start, velocity and position solve use the scaled values; zero effective mass gives 0, not infinity, and clears the cached impulses

## 3. Checks

- [x] 3.1 `bash test/run.sh` passes; every module types on `--interp`, `-hl`, `-js`
