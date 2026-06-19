class Turn
  def initialize(player:, deck:, discard_pile:)
    @player = player
    @deck = deck
    @discard_pile = discard_pile
  end

  def player
    @player
  end

  def deck
    @deck
  end

  def discard_pile
    @discard_pile
  end
end