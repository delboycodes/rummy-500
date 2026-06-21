require "domain/errors"
require "domain/turn_state"

class Turn
  attr_reader :player, :deck, :discard_pile, :state

  def initialize(player:, deck:, discard_pile:, state: TurnState.new)
    @player = player
    @deck = deck
    @discard_pile = discard_pile
    @state = state
  end

  def drawn?
    state.drawn?
  end

  def draw_from_deck
    raise TurnError, "Already drawn" if state.drawn?

    card = deck.draw
    player.hand.add(card)
    state.mark_drawn!
    card
  end

  def draw_from_discard
    raise TurnError, "Already drawn" if state.drawn?
    raise TurnError, "Discard pile empty" if discard_pile.empty?

    card = discard_pile.pop
    player.hand.add(card)
    state.mark_drawn!
    card
  end

  def discard(card)
    raise TurnError, "Must draw first" unless state.drawn?
    raise TurnError, "Already discarded" if state.discarded?

    player.hand.remove_cards([card])
    discard_pile << card
    state.mark_discarded!
    card
  end

  def complete?
    state.complete?
  end
end