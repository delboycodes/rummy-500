require "domain/player"
require "domain/card"

RSpec.describe Player do
  describe "#initialize" do
    it "stores a name" do
      player = Player.new("Linnie")

      expect(player.name).to eq("Linnie")
    end

    it "starts with an empty hand" do
      player = Player.new("Linnie")

      expect(player.hand).to be_a(Hand)
      expect(player.hand).to be_empty
    end

    it "starts with a score of zero" do
      player = Player.new("Linnie")

      expect(player.score).to eq(0)
    end

    it "accepts an existing hand" do
      hand = Hand.new([
        Card.new("A", "♠")
      ])

      player = Player.new("Linnie", hand: hand)

      expect(player.hand.size).to eq(1)
    end

    it "accepts an initial score" do
      player = Player.new("Linnie", score: 100)

      expect(player.score).to eq(100)
    end
  end

  describe "#score" do
    it "allows score updates" do
      player = Player.new("Linnie")

      player.score += 50

      expect(player.score).to eq(50)
    end
  end
end