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
    ensure_not_drawn!

    card = @deck.draw
    @player.hand.add(card)

    @has_drawn = true
    card
  end

  def draw_from_discard
    ensure_not_drawn!

    card = @discard_pile.pop
    @player.hand.add(card)

    @has_drawn = true
    card
  end

  def drawn?
    @has_drawn
  end

  def discard(card)
    ensure_drawn!
    ensure_not_discarded!
    ensure_card_in_hand!(card)

    @player.hand.remove_cards([card])
    @discard_pile << card

    @has_discarded = true
    true
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

  def ensure_card_in_hand!(card)
    unless @player.hand.cards.include?(card)
      raise TurnError, "Card not in hand"
    end
  end
end

class TurnError < StandardError; end