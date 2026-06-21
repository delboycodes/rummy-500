class TurnState
  def initialize
    @drawn = false
    @discarded = false
  end

  def mark_drawn!
    @drawn = true
  end

  def mark_discarded!
    @discarded = true
  end

  def drawn?
    @drawn
  end

  def discarded?
    @discarded
  end

  def complete?
    drawn? && discarded?
  end
end