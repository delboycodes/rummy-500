require "domain/errors"
require "domain/turn_state"

class Turn
  attr_reader :player, :deck, :discard_pile, :state, :cards_drawn_from_discard

  def initialize(player:, deck:, discard_pile:, state: TurnState.new)
    @player = player
    @deck = deck
    @discard_pile = discard_pile
    @state = state
    @cards_drawn_from_discard = nil
  end

  def drawn?
    state.drawn?
  end

  def complete?
    state.complete?
  end

  def draw_from_deck
    raise TurnError, "Already drawn" if drawn?

    card = deck.draw
    player.hand.add(card)
    state.mark_drawn!
    card
  end

  def draw_from_discard(target_card)
    raise TurnError, "Already drawn" if state.drawn?
    raise TurnError, "Discard pile empty" if discard_pile.empty?
    raise TurnError, "Card not in discard pile" unless discard_pile.include?(target_card)

    index      = discard_pile.index(target_card)
    taken_cards = discard_pile.slice!(index..)

    taken_cards.each { |card| player.hand.add(card) }

    @cards_drawn_from_discard = taken_cards
    state.mark_drawn!
  end

  def discard(card)
    raise TurnError, "Must draw first" unless state.drawn?
    raise TurnError, "Already discarded" if state.discarded?
    raise TurnError, "Cannot discard card drawn from discard pile" if discarding_drawn_card?(card)

    player.hand.remove_cards([card])
    discard_pile << card
    state.mark_discarded!
    card
  end

  private

  def discarding_drawn_card?(card)
    cards_drawn_from_discard&.include?(card)
  end
end