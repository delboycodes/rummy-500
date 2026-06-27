require "domain/cpu/opportunistic_strategy"

class StrategicStrategy < OpportunisticStrategy

  RANK_ORDER = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze

  def initialize
    @seen_discards = []
    @opponent_melds = []
  end

  def choose_discard(hand, cards_drawn_from_discard)
    candidates = eligible_for_discard(hand, cards_drawn_from_discard)
    safe_cards, risky_cards = candidates.partition { |card| safe_to_discard?(card) }
    preferred_discard_options = safe_cards.any? ? safe_cards : risky_cards

    preferred_discard_options.max_by(&:value)
  end

  def observe_turn_end(discard_pile, table)
    @seen_discards = discard_pile.dup
    @opponent_melds = table.all_melds.flat_map(&:cards)
  end

  private

  def safe_to_discard?(card)
    !extends_opponent_meld?(card) && !rank_seen_multiple_times?(card)
  end

  def extends_opponent_meld?(card)
    @opponent_melds.any? do |opponent_card|
      same_rank?(card, opponent_card) || sequential_in_suit?(card, opponent_card)
    end
  end

  def rank_seen_multiple_times?(card)
		@seen_discards
			.group_by(&:rank)
			.fetch(card.rank, [])
			.size >= 2
	end

  def same_rank?(card, other_card)
    card.rank == other_card.rank
  end

  def sequential_in_suit?(card, other_card)
		return false unless same_suit?(card, other_card)

		rank_distance(card, other_card) == 1
	end

	def same_suit?(card, other_card)
		card.suit == other_card.suit
	end

	def rank_distance(card, other_card)
		card_positions = possible_positions(card)
		other_positions = possible_positions(other_card)

		distances = card_positions.product(other_positions).map do |card_pos, other_pos|
			(card_pos - other_pos).abs
		end

		distances.min
	end

	def possible_positions(card)
		if card.rank == "A"
			[0, 13]
		else
			[RANK_ORDER.index(card.rank)]
		end
	end
end