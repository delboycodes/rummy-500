require "services/scoring_service"
require "domain/card"
require "domain/meld"
require "domain/table"
require "domain/player"

RSpec.describe ScoringService do
  def build_player(name)
    Player.new(name)
  end

  def card(rank, suit)
    Card.new(rank, suit)
  end

  describe ".calculate_round_score" do
    let(:table)  { Table.new }
    let(:player) { Player.new("Linnie") }

    it "returns 0 when the player has no melds and an empty hand" do
      expect(described_class.calculate_round_score(player: player, table: table)).to eq(0)
    end

    it "adds meld points and subtracts hand penalties" do
      table.add_meld(
        Meld.new([
          card("7", "♠"),
          card("7", "♥"),
          card("7", "♦")
        ]),
        player: player
      )

      player.hand.add(card("K", "♣"))
      player.hand.add(card("3", "♠"))

      expect(
        described_class.calculate_round_score(player: player, table: table)
      ).to eq(8)
    end

    it "values aces as 15 and face cards as 10" do
      table.add_meld(
        Meld.new([
          card("Q", "♠"),
          card("K", "♠"),
          card("A", "♠")
        ]),
        player: player
      )

      player.hand.add(card("A", "♦"))

      expect(
        described_class.calculate_round_score(player: player, table: table)
      ).to eq(20)
    end

    it "returns a negative score when hand penalties exceed meld points" do
      player.hand.add(card("A", "♣"))
      player.hand.add(card("J", "♥"))

      expect(
        described_class.calculate_round_score(player: player, table: table)
      ).to eq(-25)
    end

    it "returns 0 when meld points equal hand penalties" do
      table.add_meld(
        Meld.new([
          card("2", "♥"),
          card("3", "♥"),
          card("4", "♥")
        ]),
        player: player
      )

      player.hand.add(card("9", "♣"))

      expect(
        described_class.calculate_round_score(player: player, table: table)
      ).to eq(0)
    end

    it "correctly scores the 10 card as 10 points" do
      player.hand.add(card("10", "♠"))

      expect(
        described_class.calculate_round_score(player: player, table: table)
      ).to eq(-10)
    end

    it "only scores melds belonging to the player" do
      player1 = build_player("Linnie")
      player2 = build_player("Jake")

      table.add_meld(
        Meld.new([
          card("7", "♠"),
          card("7", "♥"),
          card("7", "♦")
        ]),
        player: player2
      )

      expect(
        described_class.calculate_round_score(player: player1, table: table)
      ).to eq(0)
    end
  end
end