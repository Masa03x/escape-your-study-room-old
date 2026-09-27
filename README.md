# Escape Your Study Room

An individual Mobile App Development project. This student wellbeing exergame turns a short study break into a playful escape challenge using physical movement.

## First portfolio feature

**Dodge the Flying Books**

> As a student taking a study break, I want to dodge flying books by squatting so that I can move while progressing through the escape game.

The first implementation now follows the new Figma Make visual direction. The Flutter feature includes the challenge preview, movement explanation, countdown, gameplay room, flying-book states, progress feedback, pause flow and completion screen.

The implementation keeps the game/sensor logic separate from the UI so the visual design can continue to improve after user testing without rewriting the movement logic.

## Repository structure

| Location | Purpose |
| --- | --- |
| `app/` | Flutter application and tests |
| `docs/features/` | Feature scope, acceptance criteria and development tasks |
| `docs/research/` | Research questions, findings and decisions |
| `docs/testing/` | User-test plans, observations and improvements |
| `assets/` | Original game images, sounds and attribution |

## Workflow

Keep GitHub issues as the backlog. Use the `feature/dodge-books` branch for the first implementation and keep `main` for reviewed work.

For portfolio evidence, record the sequence clearly: concept/design → first user test → design changes → Flutter implementation → physical-phone test → second user test → reflection.
