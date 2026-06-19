require "domain/turn"
require "domain/player"
require "domain/card"

RSpec.describe Turn do
  let(:player) { Player.new("Linnie") }
  let(:card) { Card.new("5", "♠") }
  let(:deck) { double("deck", draw: card) }
  let(:discard_pile) { [card] }

  describe "#initialize" do
    it "sets initial state correctly" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      expect(turn.player).to eq(player)
      expect(turn.deck).to eq(deck)
      expect(turn.discard_pile).to eq(discard_pile)
      expect(turn.drawn?).to eq(false)
    end
  end

  describe "#draw_from_deck" do
    it "draws a card and marks turn as drawn" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      result = turn.draw_from_deck

      expect(result).to eq(card)
      expect(turn.drawn?).to eq(true)
    end

    it "prevents drawing twice" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck

      expect {
        turn.draw_from_deck
      }.to raise_error(TurnError, "Already drawn")
    end
  end

  describe "#draw_from_discard" do
    it "draws from discard pile and marks turn as drawn" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      result = turn.draw_from_discard

      expect(result).to eq(card)
      expect(turn.drawn?).to eq(true)
    end

    it "prevents drawing after already drawing" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck

      expect {
        turn.draw_from_discard
      }.to raise_error(TurnError, "Already drawn")
    end
  end

  describe "#discard" do
    it "requires a card to be discarded after drawing" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      expect {
        turn.discard(card)
      }.to raise_error(TurnError, "Must draw first")
    end

    it "adds card to discard pile" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck
      turn.discard(card)

      expect(discard_pile.last).to eq(card)
    end

    it "prevents multiple discards" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck
      turn.discard(card)

      expect {
        turn.discard(card)
      }.to raise_error(TurnError, "Already discarded")
    end
  end

  describe "#complete?" do
    it "is false at start" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      expect(turn.complete?).to eq(false)
    end

    it "is true after draw and discard" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck
      turn.discard(card)

      expect(turn.complete?).to eq(true)
    end
  end
end