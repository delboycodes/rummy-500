require "domain/turn"
require "domain/player"
require "domain/card"
require "domain/turn_state"

RSpec.describe Turn do
  subject(:turn) do
    described_class.new(
      player: player,
      deck: deck,
      discard_pile: discard_pile,
      state: state
    )
  end

  let(:player) { Player.new("Linnie") }
  let(:card) { Card.new("5", "♠") }
  let(:deck) { instance_double("Deck", draw: card) }
  let(:discard_pile) { [] }
  let(:state) { TurnState.new }

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
      expect(turn.player).to eq(player)
      expect(turn.deck).to eq(deck)
      expect(turn.discard_pile).to eq(discard_pile)
      expect(turn.state).to eq(state)
    end

    it "starts in an un-drawn state" do
      expect(turn.drawn?).to eq(false)
    end

    it "starts with no cards drawn from the discard pile" do
      expect(turn.cards_drawn_from_discard).to be_nil
    end
  end

  describe "#draw_from_deck" do
    it "draws a card, adds it to the player's hand, and marks the turn as drawn" do
      expect(turn.draw_from_deck).to eq(card)

      expect(turn.drawn?).to eq(true)
      expect(hand).to have_received(:add).with(card)
    end

    it "prevents drawing twice" do
      turn.draw_from_deck

      expect {
        turn.draw_from_deck
      }.to raise_error(TurnError, "Already drawn")
    end

    it "does not set cards_drawn_from_discard" do
      turn.draw_from_deck

      expect(turn.cards_drawn_from_discard).to be_nil
    end
  end

  describe "#draw_from_discard" do
    it "raises if already drawn this turn" do
      discard_pile << card

      turn.draw_from_deck

      expect {
        turn.draw_from_discard(card)
      }.to raise_error(TurnError, "Already drawn")
    end

    it "raises if the discard pile is empty" do
      expect {
        turn.draw_from_discard(card)
      }.to raise_error(TurnError, "Discard pile empty")
    end

    it "raises if the target card is not in the discard pile" do
      discard_pile << card
      
      absent_card = Card.new("K", "♠")

      expect {
        turn.draw_from_discard(absent_card)
      }.to raise_error(TurnError, "Card not in discard pile")
    end

    it "takes the top card when it is the target" do
      bottom = Card.new("2", "♦")
      top = Card.new("K", "♠")

      discard_pile.push(bottom, top)

      turn.draw_from_discard(top)

      expect(discard_pile).to eq([bottom])
      expect(hand_cards).to contain_exactly(top)
    end

    it "takes the target card and all cards above it when drawing from the middle" do
      bottom = Card.new("2", "♦")
      middle = Card.new("7", "♣")
      top = Card.new("K", "♠")

      discard_pile.push(bottom, middle, top)

      turn.draw_from_discard(middle)

      expect(discard_pile).to eq([bottom])
      expect(hand_cards).to contain_exactly(middle, top)
    end

    it "clears the discard pile when drawing from the bottom" do
      bottom = Card.new("2", "♦")
      top = Card.new("K", "♠")

      discard_pile.push(bottom, top)

      turn.draw_from_discard(bottom)

      expect(discard_pile).to be_empty
      expect(hand_cards).to contain_exactly(bottom, top)
    end

    it "marks the turn as drawn" do
      discard_pile << card

      turn.draw_from_discard(card)

      expect(turn.drawn?).to eq(true)
    end

    it "tracks all cards taken from the discard pile" do
      bottom = Card.new("2", "♦")
      middle = Card.new("7", "♣")
      top = Card.new("K", "♠")

      discard_pile.push(bottom, middle, top)

      turn.draw_from_discard(middle)

      expect(turn.cards_drawn_from_discard)
        .to contain_exactly(middle, top)
    end
  end

  describe "#discard" do
    it "requires a draw first" do
      expect {
        turn.discard(card)
      }.to raise_error(TurnError, "Must draw first")
    end

    it "adds the card to the discard pile and removes it from the player's hand" do
      turn.draw_from_deck
      turn.discard(card)

      expect(discard_pile.last).to eq(card)
      expect(hand).to have_received(:remove_cards).with([card])
    end

    it "prevents multiple discards" do
      turn.draw_from_deck
      turn.discard(card)

      expect {
        turn.discard(card)
      }.to raise_error(TurnError, "Already discarded")
    end

    context "when the player drew from the discard pile" do
      it "prevents discarding the target card" do
        target = Card.new("7", "♣")

        discard_pile << target

        turn.draw_from_discard(target)

        expect {
          turn.discard(target)
        }.to raise_error(
          TurnError,
          "Cannot discard card drawn from discard pile"
        )
      end

      it "prevents discarding any scooped card" do
        bottom = Card.new("2", "♦")
        target = Card.new("7", "♣")
        scooped = Card.new("K", "♠")

        discard_pile.push(bottom, target, scooped)

        turn.draw_from_discard(target)

        expect {
          turn.discard(scooped)
        }.to raise_error(
          TurnError,
          "Cannot discard card drawn from discard pile"
        )
      end

      it "allows discarding a different card" do
        target = Card.new("7", "♣")
        other_card = Card.new("3", "♥")

        discard_pile << target
        hand_cards << other_card

        turn.draw_from_discard(target)

        expect {
          turn.discard(other_card)
        }.not_to raise_error
      end
    end

    context "when the player drew from the deck" do
      it "allows any card to be discarded" do
        other_card = Card.new("3", "♥")

        hand_cards << other_card

        turn.draw_from_deck

        expect {
          turn.discard(other_card)
        }.not_to raise_error
      end
    end
  end

  describe "#complete?" do
    it "is false at the start of the turn" do
      expect(turn.complete?).to eq(false)
    end

    it "is false after drawing only" do
      turn.draw_from_deck

      expect(turn.complete?).to eq(false)
    end

    it "is true after drawing and discarding" do
      turn.draw_from_deck
      turn.discard(card)

      expect(turn.complete?).to eq(true)
    end
  end
end