# Browser Automation Notes

Use these notes when controlling a Splendor web game with Playwright or another browser tool.

## Operating Loop

1. Open or attach to the page.
2. Take a DOM/accessibility snapshot before using element IDs or refs.
3. Extract structured game state from the page before relying on screenshots.
4. Enumerate and choose a legal move.
5. Click by stable selector, text, role, or fresh element ref.
6. Re-snapshot after every move, animation, modal, or substantial board update.

## State Extraction Order

Prefer these sources:

- App state attached to `window`, framework stores, or serialized hydration data.
- Network responses or WebSocket messages that contain room/game/action payloads.
- DOM nodes, `data-*` attributes, ARIA labels, image alt text, and button labels.
- OCR or visual inspection from screenshots only when structured state is unavailable.

Never mutate in-page state while inspecting. If using `page.evaluate`, limit it to read-only queries.

## Click Discipline

- Treat snapshot refs as temporary. Re-snapshot when the page changes or a ref fails.
- Do not click by coordinates unless selector/ref methods are unavailable.
- If coordinates are necessary, capture a fresh screenshot and use CSS-pixel coordinates. Add the clip origin back for clipped screenshots.
- Prefer a headed browser when the user is supervising play or when visual confirmation matters.
- After a click, wait for the UI to settle, then confirm the move applied by rereading board state.

## Game-Specific Cautions

- Verify it is the user's turn and the selected action is legal before clicking.
- Respect token-limit discard prompts and modal confirmations.
- Watch for drag-and-drop UIs, animated cards, disabled buttons, hidden tabs, and scrollable card rows.
- If the site exposes hidden information that a human player should not know, ignore it for strategy.
- If an action has irreversible consequences, explain the intended move and obtain user confirmation unless the user already authorized supervised automation.
