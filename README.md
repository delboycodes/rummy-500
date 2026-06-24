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
- [x] Player hands
- [x] Turn-based turn engine lifecycle
- [x] Meld validation system (sets & runs)
- [x] Core table layoff orchestration rules
- [ ] Round completion detection (Hand exhaustion)
- [ ] Scoring engine (Rummy 500 rules)
- [ ] Win condition management (500 points)
- [ ] Terminal CLI UI layer separation

---

## 🎨 Design principles

- **Domain-Driven Design:** Keep domain rules pure, isolated, and structured around aggregates and value objects without enterprise-heavy framework bloat.
- **Test-Driven Development:** Write failing specifications first to strictly drive structural contracts.
- **Separation of Concerns:** Clear isolation between core domain concepts, orchestration logic and presentation tiers.
- **Thin Presentation Layer:** The CLI acts as a thin shell reading input and translating domain outputs.
