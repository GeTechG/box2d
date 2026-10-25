# Proposal

## Why

A consumer resolves each side of a contact by that side's own collision mask (as Godot's `GodotBodyPair2D` does): a body that does not "see" the other one pushes it but is not pushed back — for that body the contact is solved as if its mass were infinite. A pair with only one seeing side can already be created through `B2ContactFilter.shouldCollide`, but the one-sided response cannot: `B2ContactSolver` reads `m_invMass` / `m_invI` straight from the bodies, a body's mass is shared by all its contacts, and `B2Contact` has no way to change it for one contact.

## What Changes

- `B2Contact` gets per-side inverse mass scales: `setInvMassScales(scaleA, scaleB)`, `getInvMassScaleA()`, `getInvMassScaleB()`. Each scale multiplies the inverse mass and the inverse rotational inertia of its body in that contact only. Default 1; reset to 1 by `B2Contact.update` before `B2ContactListener.preSolve`, like `setEnabled(true)`, so a listener sets them every step.
- `B2ContactSolver` takes the scaled values everywhere it uses inverse masses: the effective masses (`normalMass`, `equalizedMass`, `tangentMass`, the block solver's `K`), warm starting, the velocity solve and the position solve. The TOI solve of `B2Island` runs through the same solver and so gets the scales too.
- A zero effective mass (both sides scaled to 0) gives a contact that applies no impulse instead of NaN velocities.
- The fork's first test harness (`test/`), with a test of this behaviour.

## Capabilities

### New Capabilities
- `contact-inv-mass-scales`: per-contact, per-side scaling of the inverse mass and inertia used to solve a contact.
- `tests`: how the library's tests are laid out and run.

### Modified Capabilities

## Impact

`box2D/dynamics/contacts/B2Contact.hx`, `B2ContactSolver.hx`, `B2ContactConstraint.hx`; new `test/`. Additive API; with no scales set the solver computes the same numbers as before.
