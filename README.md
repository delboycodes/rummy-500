# 🃏 Rummy 500 CLI (Ruby)

A command-line implementation of the Rummy 500 card game built using Domain-Driven Design (DDD) and Test-Driven Development (TDD).

---

## 🎯 Goal

Play Rummy 500 against a simple CPU opponent in the terminal.

The objective is to reach **500 points** by forming:
- Sets (3–4 of a kind)
- Runs (3+ consecutive cards of same suit)

Play Rummy 500 against a simple CPU opponent in the terminal.

### Win Condition
The objective is to be the first player to reach **500 points** across multiple rounds.

### Core Turn Mechanics & Lifecycle

Every player’s turn moves through a set of steps in order:
1. **The Draw:** A player must start their turn by drawing. They have two distinct options:
   * **Draw from Deck:** Draw the single top card from the face-down stockpile.
   * **Deep Draw from Discard:** Pick up a specific target card from anywhere inside the face-up discard pile. Doing so forces the player to take **that target card plus every single card sitting on top of it**.
2. **Action Phase (Optional):** After drawing, the player may lay down new valid melds or lay off individual cards onto existing melds on the table.
3. **The Discard:** A player ends their turn by placing a single card from their hand face-up onto the top of the discard pile.

### Critical Turn Rule Guards
* **The Deep Draw Requirement:** If a player uses a *Deep Draw from Discard*, they face a strict penalty guard. They **must immediately play the deepest card drawn (the target card) into a valid meld or layoff on the table during that exact turn**. The other cards swept up into their hand along with it can be held for future turns. Failure to play the target card results in an illegal move validation error.
* **The Discard Loop Prevention:** A player cannot draw a single top card from the discard pile and immediately discard that exact same card back onto the pile during the same turn.

### Round Completion Rule
A single round ends immediately when:
1. **Hand Exhaustion:** A player successfully plays or lays off every single card in their hand.
2. **The Final Discard:** A player plays all but one card in their hand, then discards their final remaining card to empty their hand.

### Scoring System
At the end of a round, each player computes their score using the following valuation rules:

* **Melded Cards (Positive Points):** Points are added to the player's score for any cards they successfully placed on the table via valid sets, runs, or layoffs:
  * **Aces:** 15 points each
  * **Face Cards (J, Q, K):** 10 points each
  * **Number Cards (2–10):** Face value points (e.g., a 7 is worth 7 points)

* **Unmelded Cards (Negative Points):** Points are deducted from the player's score for any cards remaining dead in their hand at the moment the round ended:
  * Calculated using the exact same value scale as above (e.g., holding an Ace in hand costs -15 points).

* **Net Score:** A player's round score is calculated as `Total Melded Points - Total Unmelded Hand Points`. This score can be negative for a single round if a player is caught holding high-value cards in hand.

---

## 🧱 Architecture

This project follows a lightweight DDD structure:

```
lib/
├── domain/          # Core Value Objects & Aggregates
│   ├── card.rb
│   ├── deck.rb
│   ├── hand.rb
│   ├── player.rb
│   ├── meld.rb
│   ├── table.rb
│   ├── turn.rb
│   ├── turn_state.rb
│   └── errors.rb
├── services/        # Future placement for scoring & game loops
└── ui/              # CLI interface entry points
```

---

## ▶️ How to run

```
ruby bin/play
```

---

## 🧪 Run tests

```
bundle exec rspec
```

---

## 🚀 Features (WIP)

- [x] Deck shuffling and drawing
- [x] Player hands with identity-safe card removal
- [x] Turn-based turn engine lifecycle with explicit guards
- [x] Meld validation system supporting high and low Ace sequences (`A-2-3` and `Q-K-A`)
- [x] Core table layoff orchestration rules
- [x] Deep discard pile drawing mechanics with instant melding requirements
- [x] Round completion detection via hand exhaustion
- [x] Scoring engine computing combined table gains and hand penalties
- [x] Win condition management tracking scores across multiple rounds to 500 points
- [ ] Terminal CLI UI layer separation

---

## 🎨 Design principles

- **Domain-Driven Design:** Keep domain rules pure, isolated, and structured around aggregates and value objects without enterprise-heavy framework bloat.
- **Test-Driven Development:** Write failing specifications first to strictly drive structural contracts.
- **Separation of Concerns:** Clear isolation between core domain concepts, orchestration logic and presentation tiers.
- **Thin Presentation Layer:** The CLI acts as a thin shell reading input and translating domain outputs.
