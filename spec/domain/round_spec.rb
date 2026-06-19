require "domain/round"
require "domain/player"
require "domain/card"
require "domain/deck"
require "domain/table"
require "domain/turn"

RSpec.describe Round do
  def player(name)
    Player.new(name)
  end

  let(:players) { [player("Linnie"), player("Jake")] }

  def started_round(players = self.players)
    round = Round.new(players)
    round.start
    round
  end

  describe "#initialize" do
    it "sets up core aggregates" do
      round = Round.new(players)

      expect(round.players).to eq(players)
      expect(round.deck).to be_a(Deck)
      expect(round.table).to be_a(Table)
      expect(round.discard_pile).to eq([])
    end
  end

  describe "#start" do
    it "deals correct number of cards based on player count" do
      round = started_round

      expect(players.map { |p| p.hand.size }).to eq([10, 10])
    end

    it "uses 7 cards for 3+ players" do
      players = [player("A"), player("B"), player("C")]
      round = started_round(players)

      expect(players.map { |p| p.hand.size }).to eq([7, 7, 7])
    end

    it "initializes discard pile with exactly one card" do
      round = started_round

      expect(round.discard_pile.size).to eq(1)
      expect(round.discard_pile.first).to be_a(Card)
    end

    it "consumes cards from deck during deal" do
      round = Round.new(players)

      expect {
        round.start
      }.to change { round.deck.size }.by(-21)
    end
  end

  describe "#current_player" do
    it "tracks turn order" do
      round = started_round

      expect(round.current_player).to eq(players.first)
    end
  end

  describe "#end_turn" do
    it "rotates turn order deterministically" do
      round = started_round

      expect {
        round.end_turn
      }.to change { round.current_player }.from(players.first).to(players.last)
    end
  end

  describe "#current_turn" do
    it "builds a Turn object for current player" do
      round = started_round

      turn = round.current_turn

      expect(turn.player).to eq(players.first)
      expect(turn).to be_a(Turn)
    end
  end

  describe "player rules" do
    it "rejects < 2 players" do
      expect {
        Round.new([player("A")]).start
      }.to raise_error(ArgumentError)
    end

    it "rejects > 4 players" do
      players = [
        player("A"), player("B"),
        player("C"), player("D"),
        player("E")
      ]

      expect {
        Round.new(players).start
      }.to raise_error(ArgumentError)
    end
  end
end