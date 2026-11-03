# contact-inv-mass-scales Specification

## Purpose
Let a contact listener scale, per contact and per side, the inverse mass and inertia the solver uses, so one body can react to a contact as if its mass were infinite while the other reacts normally.

## Requirements

### Requirement: A contact scales the inverse mass of each side
`B2Contact` SHALL provide `setInvMassScales(scaleA:Float, scaleB:Float)`, `getInvMassScaleA():Float` and `getInvMassScaleB():Float`. When the contact is solved, the inverse mass and the inverse rotational inertia of body A SHALL be multiplied by scale A, and those of body B by scale B. Scales are non-negative.

#### Scenario: One side does not react
- **WHEN** two dynamic bodies without gravity move toward each other and the listener's `preSolve` sets scale A = 0 and scale B = 1
- **THEN** after the contact body A's velocity is unchanged and body B bounces off as from a static wall moving with A's velocity

#### Scenario: No scales set
- **WHEN** a listener does not call `setInvMassScales`
- **THEN** the bodies move exactly as they did before this capability existed

#### Scenario: Both sides scaled to zero
- **WHEN** `preSolve` sets both scales to 0
- **THEN** the contact applies no impulse, `postSolve` reports zero impulses even if the contact pushed on earlier steps, and no velocity becomes NaN

### Requirement: Scales are reset before every preSolve
Both scales SHALL be 1 when a contact is created and SHALL be set back to 1 by `B2Contact.update` before it calls `B2ContactListener.preSolve`, so a listener that wants a scale other than 1 sets it on every step.

#### Scenario: Listener stops setting the scale
- **WHEN** `preSolve` sets scale A = 0 on one step and does not set it on the next
- **THEN** on the next step both scales are 1

### Requirement: Scales apply in every phase of the contact solve
The scaled inverse masses and inertias SHALL be used in every phase of the contact solve — effective masses, warm starting, velocity iterations and position iterations — both in the regular step and in the TOI solve.

#### Scenario: Position correction
- **WHEN** scale A = 0 and the two bodies overlap
- **THEN** the position iterations move only body B to resolve the overlap

#### Scenario: TOI solve
- **WHEN** a fast bullet body B hits body A with scale A = 0 and the contact is resolved by the TOI solve
- **THEN** body A is not moved by the TOI position correction

### Requirement: Scales affect only the contact that sets them
Setting a contact's scales SHALL NOT change either body's own mass or inertia, nor how any other contact of either body is solved.

#### Scenario: Body with two contacts
- **WHEN** body A touches body B with scale A = 0 and body C with no scales set
- **THEN** `A.getMass()` is unchanged and the A–C contact is solved with A's full inverse mass
