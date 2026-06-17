require "domain/card"

class Deck
  SUITS = %w[♠ ♥ ♦ ♣].freeze
  RANKS = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze

  def initialize(cards = nil)
    @cards = cards || shuffled_deck
  end

  def draw
    @cards.pop
  end

  def size
    @cards.size
  end

  def empty?
    @cards.empty?
  end

  private

  def shuffled_deck
    SUITS.product(RANKS)
         .map { |suit, rank| Card.new(rank, suit) }
         .shuffle
  end
end