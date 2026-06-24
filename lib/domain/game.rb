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
    candidates = players.select { |p| @scores[p.name] >= WINNING_SCORE }
    return nil if candidates.empty?

    sorted_candidates = candidates.sort_by { |p| @scores[p.name] }.reverse

    if sorted_candidates.size > 1 && @scores[sorted_candidates[0].name] == @scores[sorted_candidates[1].name]
        return nil
    end

    sorted_candidates.first
    end

  def over?
    !winner.nil?
  end
end