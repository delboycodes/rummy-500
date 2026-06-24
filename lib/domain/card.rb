class Card
  attr_reader :rank, :suit

  FACE_CARDS = %w[J Q K].freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def ==(other)
    other.is_a?(Card) && rank == other.rank && suit == other.suit
  end
  alias_method :eql?, :==

  def hash
    [rank, suit].hash
  end

  def value
    return 15 if ace?
    return 10 if face_card?

    rank.to_i
  end

  def ace?
    rank == "A"
  end

  def face_card?
    FACE_CARDS.include?(rank)
  end

  def to_s
    "#{rank}#{suit}"
  end
end