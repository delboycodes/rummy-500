require "domain/round"
require "domain/player"
require "domain/card"
require "domain/deck"
require "domain/table"
require "domain/turn"
require "domain/meld"

RSpec.describe Round do
  def player(name)
    Player.new(name)
  end

  let(:players) { [player("Linnie"), player("Jake")] }

  def started_round(players = self.players)
    round = Round.new(players)
    round.start
    round
  end

  describe "#initialize" do
    it "sets up core aggregates" do
      round = Round.new(players)

      expect(round.players).to eq(players)
      expect(round.deck).to be_a(Deck)
      expect(round.table).to be_a(Table)
      expect(round.discard_pile).to eq([])
    end
  end

  describe "#start" do
    it "deals correct number of cards based on player count" do
      round = started_round
      expect(players.map { |p| p.hand.size }).to eq([10, 10])
    end

    it "uses 7 cards for 3+ players" do
      players = [player("A"), player("B"), player("C")]
      round = started_round(players)

      expect(players.map { |p| p.hand.size }).to eq([7, 7, 7])
    end

    it "initializes discard pile with exactly one card" do
      round = started_round

      expect(round.discard_pile.size).to eq(1)
      expect(round.discard_pile.first).to be_a(Card)
    end

    it "consumes cards from deck during deal" do
      round = Round.new(players)

      expect {
        round.start
      }.to change { round.deck.size }.by(-21)
    end
  end

  describe "#current_player" do
    it "tracks turn order deterministically" do
      round = started_round

      expect(round.current_player).to eq(players.first)
    end
  end

  describe "#end_turn" do
    it "requires a completed turn before rotation" do
      round = started_round

      expect {
        round.end_turn
      }.to raise_error(TurnError, "Turn not complete")
    end

    it "rotates turn deterministically after completion" do
      round = started_round

      round.current_turn.draw_from_deck
      card = round.current_player.hand.cards.first
      round.current_turn.discard(card)

      expect {
        round.end_turn
      }.to change { round.current_player }
        .from(players.first)
        .to(players.last)
    end
  end

  describe "#current_turn" do
    it "provides a valid turn for current player actions" do
      round = started_round

      turn = round.current_turn

      expect(turn).to be_a(Turn)
      expect(turn.player).to eq(players.first)
    end

    it "allows turn actions without requiring identity persistence" do
      round = started_round

      round.current_turn.draw_from_deck

      expect(round.current_player.hand.size).to be > 0
    end
  end

  describe "#play_meld" do
    let(:round) { started_round }

    let(:meld_cards) do
      [
        Card.new("7", "♠"),
        Card.new("7", "♥"),
        Card.new("7", "♦")
      ]
    end

    before do
      round.current_turn.draw_from_deck

      meld_cards.each do |card|
        round.current_player.hand.add(card)
      end
    end

    it "adds a meld to the table" do
      expect {
        round.play_meld(meld_cards)
      }.to change { round.table.size }.by(1)
    end

    it "removes melded cards from player's hand" do
      round.play_meld(meld_cards)

      meld_cards.each do |card|
        expect(round.current_player.hand.cards).not_to include(card)
      end
    end

    it "stores the meld on the table" do
      round.play_meld(meld_cards)

      expect(round.table.melds.first.cards)
        .to contain_exactly(*meld_cards)
    end

    it "rejects invalid melds" do
      invalid_cards = [
        Card.new("7", "♠"),
        Card.new("8", "♥"),
        Card.new("9", "♦")
      ]

      invalid_cards.each do |card|
        round.current_player.hand.add(card)
      end

      expect {
        round.play_meld(invalid_cards)
      }.to raise_error(ArgumentError, "Invalid meld")
    end
  end

  describe "#layoff" do
    let(:round) { started_round }

    let(:base_meld) do
      [
        Card.new("7", "♠"),
        Card.new("7", "♥"),
        Card.new("7", "♦")
      ]
    end

    let(:layoff_card) { Card.new("7", "♣") }

    before do
      round.current_turn.draw_from_deck

      base_meld.each do |card|
        round.current_player.hand.add(card)
      end

      round.play_meld(base_meld)
      round.current_player.hand.add(layoff_card)
    end

    it "adds card to existing meld via table" do
      expect {
        round.layoff([layoff_card])
      }.to change { round.table.melds.first.cards.size }.by(1)
    end

    it "removes card from player's hand when successful" do
      round.layoff([layoff_card])

      expect(round.current_player.hand.cards).not_to include(layoff_card)
    end

    it "returns true when successful" do
      expect(round.layoff([layoff_card])).to eq(true)
    end

    it "returns false when invalid" do
      bad_card = Card.new("2", "♠")
      round.current_player.hand.add(bad_card)

      expect(round.layoff([bad_card])).to eq(false)
    end
  end

  describe "#layoff to specific target" do
    let(:round) { started_round }
    let(:set_meld) { Meld.new([Card.new("7", "♠"), Card.new("7", "♥"), Card.new("7", "♦")]) }
    let(:run_meld) { Meld.new([Card.new("5", "♣"), Card.new("6", "♣"), Card.new("7", "♣")]) }

    before do
      round.current_turn.draw_from_deck
      round.table.add_meld(set_meld)
      round.table.add_meld(run_meld)
    end

    it "successfully lays off a card onto a specific target meld" do
      layoff_card = Card.new("8", "♣")
      round.current_player.hand.add(layoff_card)

      expect(round.layoff(layoff_card, target_meld: run_meld)).to eq(true)

      updated_run_meld = round.table.melds.find { |m| m.cards.include?(layoff_card) }
      expect(updated_run_meld.cards.size).to eq(4)
      expect(round.current_player.hand.cards).not_to include(layoff_card)
    end

    it "returns false and does not remove the card from hand if it is an invalid layoff for that target" do
      invalid_card = Card.new("K", "♦")
      round.current_player.hand.add(invalid_card)

      expect(round.layoff(invalid_card, target_meld: set_meld)).to eq(false)
      expect(round.current_player.hand.cards).to include(invalid_card)
    end
  end

  describe "turn flow" do
    let(:round) { started_round }

    let(:meld_cards) do
      [
        Card.new("7", "♠"),
        Card.new("7", "♥"),
        Card.new("7", "♦")
      ]
    end

    before do
      meld_cards.each do |card|
        round.current_player.hand.add(card)
      end
    end

    it "does not allow melding before drawing" do
      expect {
        round.play_meld(meld_cards)
      }.to raise_error(TurnError, "Must draw first")
    end
  end

  describe "turn flow completion" do
    let(:round) { started_round }

    it "requires discard before ending turn" do
      round.current_turn.draw_from_deck

      expect {
        round.end_turn
      }.to raise_error(TurnError, "Turn not complete")
    end

    it "allows ending turn after discard" do
      round.current_turn.draw_from_deck

      card = round.current_player.hand.cards.first
      round.current_turn.discard(card)

      expect {
        round.end_turn
      }.not_to raise_error
    end
  end

  describe "player rules" do
    it "rejects < 2 players" do
      expect {
        Round.new([player("A")]).start
      }.to raise_error(ArgumentError)
    end

    it "rejects > 4 players" do
      players = [
        player("A"), player("B"),
        player("C"), player("D"),
        player("E")
      ]

      expect {
        Round.new(players).start
      }.to raise_error(ArgumentError)
    end
  end

  describe "#completed?" do
    let(:round) { started_round }

    it "returns false when all players still have cards in hand" do
      expect(round.completed?).to eq(false)
    end

    it "returns true when a player empties their hand entirely" do
      round.current_turn.draw_from_deck
      player = round.current_player

      player.hand.cards.dup.each { |c| player.hand.remove_cards([c]) }

      expect(round.completed?).to eq(true)
    end
  end
end