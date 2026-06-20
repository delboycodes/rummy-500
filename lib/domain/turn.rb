require "domain/errors"

class Turn
  attr_reader :player, :deck, :discard_pile

  def initialize(player:, deck:, discard_pile:)
    @player = player
    @deck = deck
    @discard_pile = discard_pile

    @has_drawn = false
    @has_discarded = false
  end

  def draw_from_deck
    raise TurnError, "Already drawn" if @has_drawn

    card = @deck.draw
    @player.hand.add(card)

    @has_drawn = true
    card
  end

  def draw_from_discard
    raise TurnError, "Already drawn" if @has_drawn

    card = @discard_pile.pop
    @player.hand.add(card)

    @has_drawn = true
    card
  end

  def discard(card)
    raise TurnError, "Must draw first" unless @has_drawn
    raise TurnError, "Already discarded" if @has_discarded
    raise TurnError, "Card not in hand" unless @player.hand.cards.include?(card)

    @player.hand.remove_cards([card])
    @discard_pile << card

    @has_discarded = true
    true
  end

  def drawn?
    @has_drawn
  end

  def discarded?
    @has_discarded
  end

  def complete?
    @has_drawn && @has_discarded
  end
end