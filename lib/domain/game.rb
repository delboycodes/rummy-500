class Game
  WINNING_SCORE = 500

  attr_reader :players, :scores

  def initialize(players)
    @players = players
    @scores = players.each_with_object({}) { |p, hash| hash[p.name] = 0 }
  end

  def accumulate_scores(round_scores)
    round_scores.each do |player_name, score|
      @scores[player_name] += score if @scores.key?(player_name)
    end
  end

  def winner
    return nil if qualifying_players.empty?
    return nil if tie_for_first_place?

    leader
  end

  def over?
    !winner.nil?
  end

  private

  def qualifying_players
    players.select { |player| @scores[player.name] >= WINNING_SCORE }
  end

  def sorted_qualifiers
    qualifying_players.sort_by { |player| @scores[player.name] }.reverse
  end

  def leader
    sorted_qualifiers.first
  end

  def tie_for_first_place?
    return false if sorted_qualifiers.size < 2

    first_place_score = @scores[sorted_qualifiers[0].name]
    second_place_score = @scores[sorted_qualifiers[1].name]

    first_place_score == second_place_score
  end
end