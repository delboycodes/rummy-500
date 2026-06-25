require "domain/card"
require "domain/meld"

class Hand
  def initialize(cards = [])
    @cards = cards.dup
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

  def remove_cards(cards)
    cards.each do |card|
      raise ArgumentError, "Card not in hand" unless @cards.include?(card)
    end

    cards.each do |card|
      match_index = @cards.find_index { |c| c == card }
      @cards.delete_at(match_index) if match_index
    end
  end

  def play_meld(meld)
    raise ArgumentError, "Invalid meld" unless meld.valid?

    meld.cards.each { |card| remove(card) }

    meld
  end

  def melds
    results = []

    (3..@cards.size).each do |size|
      @cards.combination(size).each do |combo|
        meld = Meld.new(combo)
        results << meld if meld.valid?
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