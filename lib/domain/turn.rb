class Turn
  def initialize(player:, deck:, discard_pile:)
    @player = player
    @deck = deck
    @discard_pile = discard_pile

    @has_drawn = false
    @has_discarded = false
  end

  attr_reader :player, :deck, :discard_pile

  def draw_from_deck
    ensure_not_drawn!

    @has_drawn = true
    card = @deck.draw

    @player.hand.add(card)

    card
  end

  def draw_from_discard
    ensure_not_drawn!

    @has_drawn = true
    card = @discard_pile.pop

    @player.hand.add(card)

    card
  end

  def drawn?
    @has_drawn
  end

  def discard(card)
    ensure_drawn!
    ensure_not_discarded!

    @has_discarded = true
    @discard_pile << card
  end

  def discarded?
    @has_discarded
  end

  def complete?
    @has_drawn && @has_discarded
  end

  private

  def ensure_not_drawn!
    raise TurnError, "Already drawn" if @has_drawn
  end

  def ensure_drawn!
    raise TurnError, "Must draw first" unless @has_drawn
  end

  def ensure_not_discarded!
    raise TurnError, "Already discarded" if @has_discarded
  end
end

class TurnError < StandardError; end