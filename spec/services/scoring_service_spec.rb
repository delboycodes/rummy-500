require "services/scoring_service"
require "domain/card"
require "domain/hand"
require "domain/meld"
require "domain/table"
require "domain/player"

RSpec.describe ScoringService do
  describe ".calculate_round_score" do
    let(:table) { Table.new }
    let(:player) { Player.new("Linnie") }

    it "adds positive points for melded cards and subtracts negative points for unmelded cards" do
      meld = Meld.new([Card.new("7", "♠"), Card.new("7", "♥"), Card.new("7", "♦")])
      table.add_meld(meld, player: player)

      player.hand.add(Card.new("K", "♣"))
      player.hand.add(Card.new("3", "♠"))

      # Net score: (7 + 7 + 7) - (10 + 3) = 21 - 13 = 8
      net_score = ScoringService.calculate_round_score(player: player, table: table)
      expect(net_score).to eq(8)
    end

    it "correctly values Aces as 15 points and face cards as 10 points" do
      meld = Meld.new([Card.new("Q", "♠"), Card.new("K", "♠"), Card.new("A", "♠")])
      table.add_meld(meld, player: player)

      player.hand.add(Card.new("A", "♦"))

      # Net score: (10 + 10 + 15) - (15) = 35 - 15 = 20
      net_score = ScoringService.calculate_round_score(player: player, table: table)
      expect(net_score).to eq(20)
    end

    it "can return a negative net score if caught with heavy cards" do
      player.hand.add(Card.new("A", "♣"))
      player.hand.add(Card.new("J", "♥"))

      # Net score: 0 - (15 + 10) = -25
      net_score = ScoringService.calculate_round_score(player: player, table: table)
      expect(net_score).to eq(-25)
    end

    it "returns exactly 0 when meld points perfectly equal hand penalties" do
      run = Meld.new([Card.new("2", "♥"), Card.new("3", "♥"), Card.new("4", "♥")])
      table.add_meld(run, player: player)

      player.hand.add(Card.new("9", "♣"))

      # Net score: 9 - 9 = 0
      net_score = ScoringService.calculate_round_score(player: player, table: table)
      expect(net_score).to eq(0)
    end

    it "returns 0 when the player has no melds and an empty hand" do
      net_score = ScoringService.calculate_round_score(player: player, table: table)
      expect(net_score).to eq(0)
    end

    it "correctly values the 10 card as 10 points instead of truncating it" do
      player.hand.add(Card.new("10", "♠"))

      # Net score: 0 - 10 = -10
      net_score = ScoringService.calculate_round_score(player: player, table: table)
      expect(net_score).to eq(-10)
    end
  end
end