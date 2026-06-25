require "services/game_service"
require "domain/player"
require "domain/card"
require "domain/hand"

RSpec.describe GameService do
  def player(name)
    Player.new(name)
  end

  let(:players) { [player("Linnie"), player("Jake")] }
  let(:service) { GameService.new(players) }

  describe "#initialize" do
    it "builds a Game with the given players" do
      expect(service.game).to be_a(Game)
    end

    it "starts with no current round" do
      expect(service.current_round).to be_nil
    end

    it "starts with zero scores for all players" do
      expect(service.game.scores).to eq({ "Linnie" => 0, "Jake" => 0 })
    end
  end

  describe "#start_round" do
    it "creates and starts a new Round" do
      service.start_round

      expect(service.current_round).to be_a(Round)
    end

    it "deals cards to players" do
      service.start_round

      players.each do |player|
        expect(player.hand.size).to eq(10)
      end
    end

    it "resets player hands between rounds" do
      service.start_round

      # simulate end of first round — players have cards
      expect(players.first.hand.size).to eq(10)

      # force round completion then start a new one
      players.each { |p| p.hand.cards.dup.each { |c| p.hand.remove_cards([c]) } }
      service.finish_round

      service.start_round

      players.each do |player|
        expect(player.hand.size).to eq(10)
      end
    end
  end

  describe "#finish_round" do
    it "raises if no round is in progress" do
      expect {
        service.finish_round
      }.to raise_error(GameServiceError, "No round in progress")
    end

    it "raises if the round is not yet completed" do
      service.start_round

      expect {
        service.finish_round
      }.to raise_error(GameServiceError, "Round is not completed")
    end

    it "accumulates scores into the game after a completed round" do
      service.start_round

      players.each { |p| p.hand.cards.dup.each { |c| p.hand.remove_cards([c]) } }
      service.finish_round

      players.each do |player|
        expect(service.game.scores[player.name]).not_to be_nil
      end
    end

    it "returns the round scores" do
      service.start_round

      players.each { |p| p.hand.cards.dup.each { |c| p.hand.remove_cards([c]) } }
      result = service.finish_round

      expect(result.keys).to contain_exactly("Linnie", "Jake")
      result.values.each { |score| expect(score).to be_a(Integer) }
    end

    it "clears the current round after finishing" do
      service.start_round

      players.each { |p| p.hand.cards.dup.each { |c| p.hand.remove_cards([c]) } }
      service.finish_round

      expect(service.current_round).to be_nil
    end
  end

  describe "#game_over?" do
    it "returns false when no player has reached 500 points" do
      expect(service.game_over?).to eq(false)
    end

    it "returns true when a player crosses 500 points" do
      service.game.accumulate_scores({ "Linnie" => 510, "Jake" => 200 })

      expect(service.game_over?).to eq(true)
    end
  end

  describe "#winner" do
    it "returns nil when no winner yet" do
      expect(service.winner).to be_nil
    end

    it "returns the winning player once 500 is reached" do
      service.game.accumulate_scores({ "Linnie" => 510, "Jake" => 200 })

      expect(service.winner).to eq(players.first)
    end
  end
end