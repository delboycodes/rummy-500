require "domain/card"

RSpec.describe Card do
  describe "#initialize" do
    it "stores rank and suit" do
      card = Card.new("A", "♠")

      expect(card.rank).to eq("A")
      expect(card.suit).to eq("♠")
    end
  end

  describe "#==" do
    it "returns true for cards with identical rank and suit" do
      card1 = Card.new("10", "♠")
      card2 = Card.new("10", "♠")
      expect(card1).to eq(card2)
    end

    it "returns false for different ranks" do
      card1 = Card.new("10", "♠")
      card2 = Card.new("J", "♠")
      expect(card1).not_to eq(card2)
    end

    it "returns false for different suits" do
      card1 = Card.new("10", "♠")
      card2 = Card.new("10", "♥")
      expect(card1).not_to eq(card2)
    end
  end

  describe "#value" do
    it "returns 15 for an Ace" do
      expect(Card.new("A", "♠").value).to eq(15)
    end

    it "returns 10 for a Jack" do
      expect(Card.new("J", "♠").value).to eq(10)
    end

    it "returns 10 for a Queen" do
      expect(Card.new("Q", "♠").value).to eq(10)
    end

    it "returns 10 for a King" do
      expect(Card.new("K", "♠").value).to eq(10)
    end

    it "returns numeric value for number cards" do
      expect(Card.new("2", "♠").value).to eq(2)
      expect(Card.new("5", "♠").value).to eq(5)
      expect(Card.new("10", "♠").value).to eq(10)
    end
  end

  describe "#ace?" do
    it "returns true for an Ace" do
      expect(Card.new("A", "♠")).to be_ace
    end

    it "returns false for non-Aces" do
      expect(Card.new("K", "♠")).not_to be_ace
    end
  end

  describe "#face_card?" do
    it "returns true for a Jack" do
      expect(Card.new("J", "♠")).to be_face_card
    end

    it "returns true for a Queen" do
      expect(Card.new("Q", "♠")).to be_face_card
    end

    it "returns true for a King" do
      expect(Card.new("K", "♠")).to be_face_card
    end

    it "returns false for an Ace" do
      expect(Card.new("A", "♠")).not_to be_face_card
    end

    it "returns false for number cards" do
      expect(Card.new("7", "♠")).not_to be_face_card
    end
  end

  describe "#to_s" do
    it "formats an Ace correctly" do
      expect(Card.new("A", "♠").to_s).to eq("A♠")
    end

    it "formats a number card correctly" do
      expect(Card.new("10", "♣").to_s).to eq("10♣")
    end

    it "formats a face card correctly" do
      expect(Card.new("K", "♦").to_s).to eq("K♦")
    end
  end

  describe "immutability" do
    it "does not allow rank mutation" do
      card = Card.new("A", "♠")

      expect {
        card.rank = "K"
      }.to raise_error(NoMethodError)
    end

    it "does not allow suit mutation" do
      card = Card.new("A", "♠")

      expect {
        card.suit = "♥"
      }.to raise_error(NoMethodError)
    end
  end
end