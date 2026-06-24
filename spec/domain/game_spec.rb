require "domain/game"
require "domain/player"

RSpec.describe Game do
  let(:player1) { Player.new("Linnie") }
  let(:player2) { Player.new("Jake") }
  let(:game) { Game.new([player1, player2]) }

  describe "#accumulate_scores" do
    it "tracks scores across multiple rounds" do
      game.accumulate_scores({ "Linnie" => 150, "Jake" => 80 })
      expect(game.scores["Linnie"]).to eq(150)
      expect(game.scores["Jake"]).to eq(80)

      game.accumulate_scores({ "Linnie" => 100, "Jake" => 120 })
      expect(game.scores["Linnie"]).to eq(250)
      expect(game.scores["Jake"]).to eq(200)
    end
  end

  describe "#winner" do
    it "returns nil if no player has reached 500 points" do
      game.accumulate_scores({ "Linnie" => 450, "Jake" => 300 })
      expect(game.winner).to be_nil
    end

    it "returns the player who crosses 500 points" do
      game.accumulate_scores({ "Linnie" => 510, "Jake" => 400 })
      expect(game.winner).to eq(player1)
    end

    it "handles ties by picking the higher score if both cross 500" do
      game.accumulate_scores({ "Linnie" => 520, "Jake" => 550 })
      expect(game.winner).to eq(player2)
    end

    it "returns nil in the event of an exact tie above 500 points to trigger another round" do
      game.accumulate_scores({ "Linnie" => 550, "Jake" => 550 })
      expect(game.winner).to be_nil
      expect(game.over?).to eq(false)
    end
  end

  describe "#over?" do
    it "returns true only when a winner is determined" do
      expect(game.over?).to eq(false)
      game.accumulate_scores({ "Linnie" => 505, "Jake" => 200 })
      expect(game.over?).to eq(true)
    end
  end
end