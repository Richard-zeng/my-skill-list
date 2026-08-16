# Splendor Strategy Notes

Use these heuristics after legality is established. Adapt to player count and the visible board.

## Priorities

1. Convert resources into permanent discounts early.
   - Tier 1 cards with 2-3 total cost are usually strong when they unlock multiple future buys.
   - Avoid collecting gems without a target unless denying or preserving flexibility.

2. Build toward point density.
   - Midgame tempo often comes from cards worth 1-3 points that also satisfy future costs.
   - A high-tier card is attractive when the player already covers at least half its cost with bonuses.

3. Track noble pressure.
   - If a noble requires 3-4 bonuses in colors already useful for visible point cards, treat it as a real plan.
   - Do not chase a noble that forces low-value purchases while opponents score faster.

4. Reserve selectively.
   - Reserve when a card is high value for the player, high value for an opponent, or needs gold to bridge a near-term purchase.
   - Reserve less when already behind on tempo, near the reserve limit, or gold is unavailable.

5. Deny when denial is cheap.
   - Denial is strongest when it also improves your own plan: taking needed gems, reserving a card you can later buy, or blocking an opponent's immediate point swing.
   - Pure denial is weaker in 3-4 player games unless it prevents a win or noble.

## Move Evaluation

Score a move by combining:

- Immediate points gained.
- Permanent bonus value, weighted by visible costs and noble costs.
- Next-turn readiness: whether the move creates a clear affordable buy.
- Scarcity: whether the needed gems are low in the bank or contested.
- Opponent threats: visible affordable point cards or noble completion.

## Common Patterns

- If a zero-point card is free or nearly free and its color is useful, buying it is often better than taking more gems.
- Taking 3 different gems is best when it enables two possible buys next turn.
- Taking 2 same-color gems is best when it directly enables a strong card and leaves at least 2 of that color in the bank after taking.
- Buying a weak card just to use tokens can be correct when at token limit, but prefer cards that align with a noble or high-tier cost.
- In endgame, points and denial outweigh engine growth. Recompute whether any move lets a player reach or exceed 15.

## Browser Play Discipline

- Verify whose turn it is before clicking.
- Prefer selecting a card by stable text, `data-*` attributes, or index within a parsed card list rather than screen coordinates.
- After each move, re-read state. Web animations and async updates can make stale screenshots misleading.
- If the game has hidden deck order or private opponent reserves, do not infer beyond visible information unless the page exposes it as public state.
