class ScoringService
  FACE_CARD_VALUES = { "J" => 10, "Q" => 10, "K" => 10, "A" => 15 }.freeze

  def self.calculate_round_score(player:, table:)
    player_melds = table.melds_for(player)
    
    meld_points = player_melds.sum do |meld|
      meld.cards.sum { |card| card_value(card) }
    end

    hand_penalty = player.hand.cards.sum { |card| card_value(card) }

    meld_points - hand_penalty
  end

  private

  def self.card_value(card)
    if card.rank =~ /^\d+$/
      card.rank.to_i
    else
      FACE_CARD_VALUES.fetch(card.rank)
    end
  end
end