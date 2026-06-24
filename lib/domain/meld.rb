class Meld
  ACE_LOW_RANKS  = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze
  ACE_HIGH_RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

  def initialize(cards)
    @cards = cards.dup
  end

  def valid?
    set? || run?
  end

  def cards
    @cards.dup
  end

  def ==(other)
    other.is_a?(Meld) && cards == other.cards
  end
  alias_method :eql?, :==

  def hash
    cards.hash
  end

  private

  def set?
    @cards.size.between?(3, 4) && same_rank?
  end

  def run?
    return false unless @cards.size >= 3
    return false unless same_suit?

    consecutive_in?(ACE_LOW_RANKS) ||
      consecutive_in?(ACE_HIGH_RANKS)
  end

  def consecutive_in?(rank_order)
    indices = @cards.map { |card| rank_order.index(card.rank) }

    return false if indices.any?(&:nil?)
    return false if indices.uniq.size != indices.size

    indices.sort.each_cons(2).all? do |a, b|
      b == a + 1
    end
  end

  def same_rank?
    @cards.all? { |card| card.rank == @cards.first.rank }
  end

  def same_suit?
    @cards.all? { |card| card.suit == @cards.first.suit }
  end
end