require "domain/cpu/strategy"
require "domain/meld"

class OpportunisticStrategy < CpuStrategy
  def choose_draw(hand, discard_pile)
    discard_pile.reverse_each.find do |card|
      index = discard_pile.index(card)
      potential_hand = hand.cards + discard_pile[index..]

      completes_meld?(potential_hand)
    end
  end

  def choose_melds(hand, table)
    remaining_cards = hand.cards.dup
    melds = []

    loop do
      meld_cards = playable_meld_from(remaining_cards)
      break unless meld_cards

      melds << meld_cards
      remaining_cards -= meld_cards
    end

    melds
  end

  def choose_layoffs(hand, table)
    remaining_cards = hand.cards.dup
    layoffs = []

    table.all_melds.each do |meld|
      cards_that_extend(remaining_cards, meld).each do |card|
        layoffs << { cards: [card], target_meld: meld }
        remaining_cards -= [card]
      end
    end

    layoffs
  end

  def choose_discard(hand, cards_drawn_from_discard)
    eligible_for_discard(hand, cards_drawn_from_discard).max_by(&:value)
  end

  private

  def cards_that_extend(remaining_cards, meld)
    remaining_cards.select { |card| Meld.new(meld.cards + [card]).valid? }
  end

  def eligible_for_discard(hand, cards_drawn_from_discard)
    protected_cards = Array(cards_drawn_from_discard)
    hand.cards.reject { |card| protected_cards.include?(card) }
  end

  def completes_meld?(cards)
    cards.combination(3).any? { |combo| Meld.new(combo).valid? }
  end

  def playable_meld_from(cards)
    (3..cards.size).each do |size|
      cards.combination(size).each do |combo|
        return combo if Meld.new(combo).valid?
      end
    end

    nil
  end
end