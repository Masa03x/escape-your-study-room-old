# First feature: Dodge flying books

Status: initial Flutter source prototype written; research, user testing and full Flutter validation pending. See app/README.md for setup and limitations.

Backlog: [issue #4](https://github.com/Masa03x/escape-your-study-room/issues/4).

## User story

As a student taking a study break, I want to dodge flying books by squatting so that I can move while progressing through the escape game.

## Why start here?

This feature combines the main game idea with physical movement. It gives me a small part of the app that I can research, design, test, build and improve for my first portfolio submission.

## Proposed first version

1. Read short movement and phone-holding instructions.
2. Start a short challenge.
3. See a flying book and a clear cue to dodge.
4. Perform the movement; the game reacts and updates progress.
5. Pause, resume or leave when needed.
6. See a clear ending and put the phone away.

For the first prototype, use a provisional goal of five successful dodges. This number is a design assumption to test, not a research finding. Instructions, progress, pause and completion are small supporting parts of this flow, linked to existing issues #2, #3, #5, #6 and #8.

## Acceptance criteria

- Instructions explain the movement and the tested phone position before starting.
- One accepted movement during a dodge opportunity triggers one dodge and adds one point.
- A sustained movement or sensor noise cannot repeatedly increase the score.
- Input outside an active dodge opportunity does not increase progress.
- Feedback clearly shows whether a dodge counted.
- Pausing stops gameplay and ignores movement input. Resuming resets pending detection so it cannot award a stale dodge.
- Leaving stops the session and sensor subscription.
- Reaching the goal shows completion and stops counting.
- Backgrounding the app pauses the challenge.
- Movement recognition is tested on a physical phone. A manual prototype control does not count as sensor validation.

## Questions to resolve before implementation

- Which framework will I use?
- Where should the player hold the phone so the screen is readable and movement is detectable?
- Can the phone distinguish the intended movement from ordinary handling well enough for this prototype?
- Should detection count the downward motion or a complete down-and-up cycle?
- How long should a dodge opportunity last?

A phone sensor measures phone movement; it cannot prove correct squat form. The detector should be described and evaluated as a movement estimate.

## Work checklist

- [ ] Answer the research questions and record sources or observations.
- [ ] Sketch instructions, gameplay and completion screens.
- [ ] Create an interactive concept prototype.
- [ ] Run the first user test and record real observations.
- [ ] Improve the concept based on feedback.
- [ ] Scaffold the mobile app.
- [ ] Build the challenge flow and game state.
- [ ] Experiment with physical-phone sensor readings.
- [ ] Connect movement detection to the dodge mechanic.
- [ ] Test counting, pause/resume, leaving and completion.
- [ ] Retest with users on a physical phone.
- [ ] Record changes, limitations and reflection.

## Evidence

Use the [research notes](../research/dodge-books.md) and [testing plan](../testing/dodge-books.md). Add screenshots and commit links as the work happens. Do not mark tasks as finished until they have actually been completed.
