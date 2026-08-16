---
name: splendor-web-player
description: Assist playing the web board game Splendor / 璀璨宝石 in a browser. Use when the user asks Codex to play, analyze, automate, inspect, recommend moves for, or help win an online Splendor game, including reading browser state, evaluating legal actions, and using Playwright safely.
---

# Splendor Web Player

Use this skill to help a user play Splendor in a web browser. Combine browser inspection, legal-move validation, and Splendor-specific strategy. Do not assume the UI or rules variant; confirm them from the page before acting.

## Workflow

1. Establish the game context.
   - Ask for or locate the game URL if it is not already open.
   - Identify whether the user wants advice only, supervised clicking, or full browser operation.
   - Confirm the variant: base Splendor, Cities, Orient, Trading Posts, custom rules, bot/table settings, and player count.

2. Inspect the board before every recommendation.
   - Capture visible cards, nobles/tiles, bank tokens, each player's gems, bonuses, reserved cards, points, and turn indicator.
   - Prefer structured data from the DOM, app state, network responses, localStorage, or page scripts. Use OCR or screenshot inspection only when structured data is unavailable.
   - Record uncertainty explicitly. Never click a move when card cost, token counts, or turn ownership is uncertain.

3. Enumerate legal actions.
   - Buy an affordable visible or reserved card.
   - Reserve one visible deck/top card if the UI allows it, taking gold only when available.
   - Take 3 different gems, or 2 of the same gem only when the bank has at least 4 of that color.
   - Enforce hand/token limits shown by the site, including discards after token taking.

4. Score candidate moves.
   - For tactical strategy, read `references/strategy.md`.
   - If a JSON board snapshot is available, run `scripts/evaluate_state.py` to rank candidates.
   - Prefer a short move rationale: immediate points, engine value, noble pressure, denial value, and risk.

5. Act carefully in the browser.
   - Use Playwright/browser tools when available.
   - For browser-operation details, read `references/browser-automation.md`.
   - Before clicking, verify selectors and board coordinates against a fresh screenshot or DOM snapshot.
   - After clicking, confirm the move applied and update the board state.

## Browser State Capture

Use this order when inspecting a web implementation:

1. DOM text and ARIA labels: card names, costs, points, gem icons, buttons.
2. In-page JavaScript state: inspect obvious global variables and framework stores without mutating them.
3. Network/local storage: look for serialized game state, player IDs, room IDs, or action payloads.
4. Screenshots: use only for cross-checking layout or when state is not exposed structurally.

When generating automation, keep it site-local and reversible. Do not bypass matchmaking, hidden information, rate limits, authentication, or payment gates. Do not use actions unavailable to a human player.

If existing browser automation skills are available, use them as supporting skills:

- Use `$playwright` for CLI-first browser control, snapshots, screenshots, and stable element refs.
- Use `$playwright-interactive` for a persistent Playwright session through `node_repl` when repeated inspection/clicking is needed.
- Do not install low-quality generic "unblocked game" skills just because they mention browser games; prefer direct browser automation plus this Splendor-specific strategy layer.

## JSON Evaluation Script

Use `scripts/evaluate_state.py` when the board can be expressed as JSON. The script expects:

```json
{
  "player": {
    "tokens": {"white": 0, "blue": 0, "green": 0, "red": 0, "black": 0, "gold": 0},
    "bonuses": {"white": 0, "blue": 0, "green": 0, "red": 0, "black": 0},
    "points": 0,
    "reserved_count": 0
  },
  "bank": {"white": 4, "blue": 4, "green": 4, "red": 4, "black": 4, "gold": 5},
  "visible_cards": [
    {"id": "1A", "tier": 1, "color": "blue", "points": 0, "cost": {"white": 1, "red": 1}}
  ],
  "nobles": [
    {"id": "N1", "points": 3, "cost": {"white": 4, "blue": 4}}
  ]
}
```

Run:

```bash
python .agents/skills/splendor-web-player/scripts/evaluate_state.py state.json
```

Output is JSON with ranked actions and reasons. Treat it as an aide, then check legality and UI state again before acting.

## Reporting Moves

When advising the user, respond in Chinese if the user is using Chinese. Use this compact form:

- Best move: buy/reserve/take tokens, with exact card or colors.
- Why: 2-4 concrete reasons.
- Watch out: one risk or fallback if the UI state differs.
