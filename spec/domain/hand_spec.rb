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
  end
end