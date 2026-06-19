require "domain/hand"
require "domain/card"

RSpec.describe Hand do
  let(:hand) { Hand.new }

  def card(rank, suit)
    Card.new(rank, suit)
  end

  describe "#initialize" do
    it "starts empty by default" do
      expect(hand.size).to eq(0)
      expect(hand).to be_empty
    end
  end

  describe "#add" do
    it "adds cards to the hand" do
      hand.add(card("A", "♠"))

      expect(hand.size).to eq(1)
    end
  end

  describe "#remove" do
    it "removes matching cards from the hand" do
      hand_with_card = Hand.new([card("A", "♠")])

      hand_with_card.remove(card("A", "♠"))

      expect(hand_with_card).to be_empty
    end

    it "does nothing if card is not found" do
      hand_with_card = Hand.new([card("A", "♠")])

      hand_with_card.remove(card("K", "♦"))

      expect(hand_with_card.size).to eq(1)
    end
  end

  describe "#remove_cards" do
    let(:hand) { Hand.new }

    let(:five_spades) { Card.new("5", "♠") }
    let(:five_hearts) { Card.new("5", "♥") }
    let(:five_diamonds) { Card.new("5", "♦") }

    before do
      hand.add(five_spades)
      hand.add(five_hearts)
      hand.add(five_diamonds)
    end

    it "removes multiple cards" do
      hand.remove_cards([
        five_spades,
        five_hearts
      ])

      expect(hand.cards).to contain_exactly(
        five_diamonds
      )
    end

    it "raises when a card is missing" do
      hand = Hand.new

      card = Card.new("5", "♠")

      expect {
        hand.remove_cards([card])
      }.to raise_error(
        ArgumentError,
        "Card not in hand"
      )
    end
  end

  describe "#play_meld" do
    it "removes meld cards from hand" do
      hand = Hand.new([
        card("7", "♠"),
        card("7", "♥"),
        card("7", "♦")
      ])

      meld = Meld.new(hand.cards)

      hand.play_meld(meld)

      expect(hand).to be_empty
    end

    it "raises error for invalid meld" do
      hand = Hand.new([
        card("7", "♠"),
        card("8", "♥"),
        card("9", "♦")
      ])

      meld = Meld.new(hand.cards)

      expect(meld.valid?).to be false

      expect {
        hand.play_meld(meld)
      }.to raise_error(ArgumentError)
    end
  end

  describe "#melds" do
    it "finds a 3-of-a-kind set" do
      hand.add(card("7", "♠"))
      hand.add(card("7", "♥"))
      hand.add(card("7", "♦"))

      expect(hand.melds.size).to eq(1)
    end

    it "finds a run" do
      hand.add(card("4", "♠"))
      hand.add(card("5", "♠"))
      hand.add(card("6", "♠"))

      expect(hand.melds.size).to eq(1)
    end

    it "returns empty when no melds exist" do
      hand.add(card("2", "♠"))
      hand.add(card("5", "♦"))
      hand.add(card("9", "♥"))

      expect(hand.melds).to be_empty
    end
  end

  describe "#cards" do
    it "returns a copy of cards" do
      hand.add(card("A", "♠"))

      external = hand.cards
      external << card("K", "♦")

      expect(hand.size).to eq(1)
    end
  end
end