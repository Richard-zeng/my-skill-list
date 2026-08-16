#!/usr/bin/env python3
"""Rank simple Splendor actions from a JSON board snapshot."""

from __future__ import annotations

import itertools
import json
import sys
from pathlib import Path
from typing import Any


COLORS = ("white", "blue", "green", "red", "black")


def color_map(value: dict[str, int] | None, include_gold: bool = False) -> dict[str, int]:
    keys = COLORS + (("gold",) if include_gold else ())
    return {color: int((value or {}).get(color, 0)) for color in keys}


def missing_cost(card: dict[str, Any], player: dict[str, Any]) -> dict[str, int]:
    bonuses = color_map(player.get("bonuses"))
    tokens = color_map(player.get("tokens"), include_gold=True)
    missing: dict[str, int] = {}
    for color in COLORS:
        need = max(0, int(card.get("cost", {}).get(color, 0)) - bonuses[color])
        missing[color] = max(0, need - tokens[color])
    gold_available = tokens.get("gold", 0)
    for color in COLORS:
        use = min(missing[color], gold_available)
        missing[color] -= use
        gold_available -= use
    return missing


def is_affordable(card: dict[str, Any], player: dict[str, Any]) -> bool:
    return sum(missing_cost(card, player).values()) == 0


def card_need_after_tokens(
    card: dict[str, Any], player: dict[str, Any], gained: dict[str, int]
) -> int:
    updated = dict(player)
    tokens = color_map(player.get("tokens"), include_gold=True)
    for color, count in gained.items():
        tokens[color] = tokens.get(color, 0) + count
    updated["tokens"] = tokens
    return sum(missing_cost(card, updated).values())


def visible_color_demand(state: dict[str, Any]) -> dict[str, float]:
    demand = {color: 0.0 for color in COLORS}
    for card in state.get("visible_cards", []):
        tier = int(card.get("tier", 1) or 1)
        weight = 1.0 / max(tier, 1)
        for color in COLORS:
            demand[color] += int(card.get("cost", {}).get(color, 0)) * weight
    for noble in state.get("nobles", []):
        for color in COLORS:
            demand[color] += int(noble.get("cost", {}).get(color, 0)) * 0.35
    return demand


def noble_progress_after_card(
    state: dict[str, Any], player: dict[str, Any], card: dict[str, Any] | None
) -> float:
    bonuses = color_map(player.get("bonuses"))
    if card and card.get("color") in COLORS:
        bonuses[card["color"]] += 1
    best = 0.0
    for noble in state.get("nobles", []):
        cost = color_map(noble.get("cost"))
        total = sum(cost.values()) or 1
        have = sum(min(bonuses[color], cost[color]) for color in COLORS)
        best = max(best, have / total)
    return best


def score_buy(state: dict[str, Any], card: dict[str, Any]) -> tuple[float, list[str]]:
    player = state["player"]
    demand = visible_color_demand(state)
    points = int(card.get("points", 0))
    color = card.get("color")
    tier = int(card.get("tier", 1) or 1)
    engine = demand.get(color, 0.0) * 0.18 if color in COLORS else 0.0
    noble = noble_progress_after_card(state, player, card) * 1.4
    cost_total = sum(int(v) for v in card.get("cost", {}).values())
    tier_penalty = max(0, tier - 1) * 0.15
    score = points * 3.0 + engine + noble - cost_total * 0.05 - tier_penalty
    reasons = [f"+{points} points", f"{color} bonus"] if color else [f"+{points} points"]
    if noble >= 0.9:
        reasons.append("strong noble progress")
    if engine >= 0.8:
        reasons.append("bonus color is in demand")
    return round(score, 3), reasons


def score_reserve(state: dict[str, Any], card: dict[str, Any]) -> tuple[float, list[str]]:
    player = state["player"]
    bank = color_map(state.get("bank"), include_gold=True)
    missing = sum(missing_cost(card, player).values())
    points = int(card.get("points", 0))
    demand = visible_color_demand(state)
    color = card.get("color")
    reserve_room = max(0, 3 - int(player.get("reserved_count", 0)))
    gold_value = 0.9 if bank.get("gold", 0) > 0 else 0.0
    near_buy = max(0, 3 - missing) * 0.45
    color_value = demand.get(color, 0.0) * 0.08 if color in COLORS else 0.0
    score = points * 1.6 + gold_value + near_buy + color_value + reserve_room * 0.2
    if reserve_room <= 0:
        score -= 4.0
    reasons = [f"{points} point card", f"{missing} resources short"]
    if gold_value:
        reasons.append("takes gold")
    if reserve_room <= 0:
        reasons.append("reserve limit reached")
    return round(score, 3), reasons


def score_tokens(state: dict[str, Any], gained: dict[str, int]) -> tuple[float, list[str]]:
    player = state["player"]
    bank = color_map(state.get("bank"), include_gold=True)
    best_improvement = 0
    enabled: list[str] = []
    for card in state.get("visible_cards", []):
        before = sum(missing_cost(card, player).values())
        after = card_need_after_tokens(card, player, gained)
        improvement = before - after
        best_improvement = max(best_improvement, improvement)
        if after == 0 and before > 0:
            enabled.append(str(card.get("id", "visible card")))
    scarcity = sum(0.15 for color in gained if bank.get(color, 0) <= 2)
    diversity = len(gained) * 0.25
    score = best_improvement * 1.1 + len(enabled) * 1.5 + diversity + scarcity
    reasons = [f"improves card affordability by {best_improvement}"]
    if enabled:
        reasons.append("enables " + ", ".join(enabled[:3]))
    return round(score, 3), reasons


def candidate_token_takes(state: dict[str, Any]) -> list[dict[str, int]]:
    bank = color_map(state.get("bank"), include_gold=True)
    takes: list[dict[str, int]] = []
    available = [color for color in COLORS if bank[color] > 0]
    for combo in itertools.combinations(available, min(3, len(available))):
        takes.append({color: 1 for color in combo})
    for color in COLORS:
        if bank[color] >= 4:
            takes.append({color: 2})
    return takes


def rank_actions(state: dict[str, Any]) -> list[dict[str, Any]]:
    player = state.get("player", {})
    state = {**state, "player": player}
    actions: list[dict[str, Any]] = []

    for card in state.get("visible_cards", []):
        if is_affordable(card, player):
            score, reasons = score_buy(state, card)
            actions.append(
                {
                    "action": "buy",
                    "card_id": card.get("id"),
                    "score": score,
                    "reasons": reasons,
                }
            )
        score, reasons = score_reserve(state, card)
        actions.append(
            {
                "action": "reserve",
                "card_id": card.get("id"),
                "score": score,
                "reasons": reasons,
            }
        )

    for gained in candidate_token_takes(state):
        score, reasons = score_tokens(state, gained)
        actions.append(
            {"action": "take_tokens", "tokens": gained, "score": score, "reasons": reasons}
        )

    return sorted(actions, key=lambda item: item["score"], reverse=True)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: evaluate_state.py <state.json|->", file=sys.stderr)
        return 2
    if sys.argv[1] == "-":
        state = json.loads(sys.stdin.read())
    else:
        path = Path(sys.argv[1])
        state = json.loads(path.read_text(encoding="utf-8"))
    result = {"top_actions": rank_actions(state)[:10]}
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
