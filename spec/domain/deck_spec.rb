require "domain/deck"
require "domain/card"

RSpec.describe Deck do
  let(:deck) { Deck.new }

  def card(rank, suit)
    Card.new(rank, suit)
  end

  describe "#initialize" do
    it "builds a full deck by default" do
      expect(deck.size).to eq(52)
    end
  end

  describe "#draw" do
    it "returns a card" do
      expect(deck.draw).to be_a(Card)
    end

    it "reduces deck size by 1" do
      expect { deck.draw }
        .to change(deck, :size)
        .by(-1)
    end

    it "draws cards from the top of the deck" do
      deck = Deck.new([
        card("A", "♠"),
        card("K", "♠"),
        card("Q", "♠")
      ])

      first_card = deck.draw
			second_card = deck.draw

			expect(first_card.rank).to eq("Q")
			expect(second_card.rank).to eq("K")
    end
  end

  describe "#size" do
    it "returns number of cards remaining" do
      expect(Deck.new([card("A", "♠")]).size).to eq(1)
    end
  end

  describe "#empty?" do
    it "is true when deck has no cards" do
      expect(Deck.new([])).to be_empty
    end

    it "is false when deck has cards" do
      expect(deck).not_to be_empty
    end
  end

  describe "custom deck" do
    it "uses provided cards instead of generating a new deck" do
      deck = Deck.new([
        card("2", "♠"),
        card("3", "♠")
      ])

      first_card = deck.draw
			second_card = deck.draw

			expect(first_card.rank).to eq("3")
			expect(second_card.rank).to eq("2")
    end
  end
end