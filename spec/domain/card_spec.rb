require "domain/card"

RSpec.describe Card do
  describe "#attributes" do
    it "stores rank and suit" do
      card = Card.new("A", "♠")

      expect(card.rank).to eq("A")
      expect(card.suit).to eq("♠")
    end
  end

  describe "#value" do
    it "returns 15 for Ace" do
      expect(Card.new("A", "♠").value).to eq(15)
    end

    it "returns numeric value for number cards" do
      expect(Card.new("5", "♥").value).to eq(5)
    end

    it "returns 10 for King" do
      expect(Card.new("K", "♦").value).to eq(10)
    end
  end

  describe "#to_s" do
    it "formats card correctly" do
      expect(Card.new("10", "♣").to_s).to eq("10♣")
    end
  end
end