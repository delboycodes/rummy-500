require "domain/turn"
require "domain/player"
require "domain/card"

RSpec.describe Turn do
  let(:player) { Player.new("Linnie") }
  let(:card) { Card.new("5", "♠") }

  let(:deck) { double("deck", draw: card) }
  let(:discard_pile) { [] }

  let(:hand) { instance_double("Hand") }
  let(:hand_cards) { [] }

  before do
    allow(player).to receive(:hand).and_return(hand)

    allow(hand).to receive(:add) do |c|
      hand_cards << c
    end

    allow(hand).to receive(:remove_cards) do |cards|
      cards.each { |c| hand_cards.delete(c) }
    end

    allow(hand).to receive(:cards).and_return(hand_cards)
  end

  describe "#initialize" do
    it "assigns dependencies" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      expect(turn.player).to eq(player)
      expect(turn.deck).to eq(deck)
      expect(turn.discard_pile).to eq(discard_pile)
    end

    it "starts in un-drawn state" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      expect(turn.drawn?).to eq(false)
    end
  end

  describe "#draw_from_deck" do
    it "draws a card, adds it to player's hand, and marks turn as drawn" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      result = turn.draw_from_deck

      expect(result).to eq(card)
      expect(turn.drawn?).to eq(true)
      expect(hand).to have_received(:add).with(card)
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
    it "draws from discard pile and adds it to player's hand" do
      discard_pile << card

      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      result = turn.draw_from_discard

      expect(result).to eq(card)
      expect(turn.drawn?).to eq(true)
      expect(hand).to have_received(:add).with(card)
    end

    it "removes card from discard pile" do
      discard_pile << card

      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_discard

      expect(discard_pile).to be_empty
    end

    it "prevents drawing after already drawn" do
      discard_pile << card

      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck

      expect {
        turn.draw_from_discard
      }.to raise_error(TurnError, "Already drawn")
    end
  end

  describe "#discard" do
    it "requires a draw first" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      expect {
        turn.discard(card)
      }.to raise_error(TurnError, "Must draw first")
    end

    it "adds card to discard pile and removes it from hand" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck
      turn.discard(card)

      expect(discard_pile.last).to eq(card)
      expect(hand).to have_received(:remove_cards).with([card])
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

    it "is false after only drawing" do
      turn = Turn.new(player: player, deck: deck, discard_pile: discard_pile)

      turn.draw_from_deck

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