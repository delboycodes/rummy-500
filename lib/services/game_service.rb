require "domain/game"
require "domain/round"
require "services/scoring_service"

class GameService
  attr_reader :game, :current_round

  def initialize(players)
    @game = Game.new(players)
    @current_round = nil
  end

  def start_round
    reset_player_hands!
    @current_round = Round.new(@game.players).start
  end

  def finish_round
    raise GameServiceError, "No round in progress" unless current_round
    raise GameServiceError, "Round is not completed" unless current_round.completed?

    round_scores = calculate_scores
    @game.accumulate_scores(round_scores)
    @current_round = nil

    round_scores
  end

  def game_over?
    @game.over?
  end

  def winner
    @game.winner
  end

  private

  def calculate_scores
    @game.players.each_with_object({}) do |player, scores|
      scores[player.name] = ScoringService.calculate_round_score(
        player: player,
        table:  current_round.table
      )
    end
  end

  def reset_player_hands!
    @game.players.each { |player| player.hand = Hand.new }
  end
end