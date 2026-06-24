require "domain/meld"

class Table
  def initialize
    @melds = []
  end

  def add_meld(meld)
    raise ArgumentError, "Invalid meld" unless meld.valid?

    @melds << clone_meld(meld)
  end


  def layoff(input_cards, target_meld: nil)
    cards = Array(input_cards)
    return false if cards.empty?

    target = target_meld || find_layoff_target(cards)
    return false unless target && @melds.include?(target)

    new_cards = target.cards + cards
    new_meld = Meld.new(new_cards)

    return false unless new_meld.valid?

    @melds.delete(target)
    @melds << clone_meld(new_meld)

    true
  end

  def melds
    @melds.dup
  end

  def size
    @melds.size
  end

  def empty?
    @melds.empty?
  end

  private

  def find_layoff_target(cards)
    @melds.find do |meld|
      Meld.new(meld.cards + cards).valid?
    end
  end

  def clone_meld(meld)
    Meld.new(meld.cards)
  end
end