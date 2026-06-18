require "domain/meld"

class Table
  def initialize
    @melds = []
  end

  def add_meld(meld)
    raise ArgumentError, "Invalid meld" unless meld.valid?

    @melds << freeze_meld(meld)
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

  def freeze_meld(meld)
    Meld.new(meld.cards)
  end
end