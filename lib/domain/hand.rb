require "domain/card"
require "domain/meld"

class Hand
  def initialize(cards = [])
    @cards = cards
  end

  def add(card)
    @cards << card
  end

  def remove(card)
    index = @cards.find_index do |c|
      c.rank == card.rank && c.suit == card.suit
    end

    @cards.delete_at(index) if index
  end

  def melds
    results = []

    (3..@cards.size).each do |size|
      @cards.combination(size).each do |combo|
        results << combo if Meld.new(combo).valid?
      end
    end

    results
  end

  def cards
    @cards.dup
  end

  def size
    @cards.size
  end

  def empty?
    @cards.empty?
  end
end