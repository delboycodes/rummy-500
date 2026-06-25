class ScoringService
  def self.calculate_round_score(player:, table:)
    player_melds = table.melds_for(player)

    meld_points = player_melds.sum { |meld| meld.cards.sum(&:value) }
    hand_penalty = player.hand.cards.sum(&:value)

    meld_points - hand_penalty
  end
end