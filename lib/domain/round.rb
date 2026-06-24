require "domain/deck"
require "domain/table"
require "domain/turn"
require "domain/turn_state"
require "domain/meld"
require "domain/errors"

class Round
  attr_reader :players, :deck, :table, :discard_pile

  def initialize(players, deck: Deck.new, table: Table.new)
    @players = players
    @deck = deck
    @table = table
    @discard_pile = []

    @current_index = 0
    @current_turn = nil
  end

  def start
    validate_players!
    deal_cards
    start_discard_pile
    start_turn
    self
  end

  def current_player
    players[@current_index]
  end

  def current_turn
    @current_turn
  end

  def end_turn
    ensure_turn_complete!

    @current_index = (@current_index + 1) % players.size
    start_turn
  end

  def play_meld(cards)
    raise TurnError, "Must draw first" unless current_turn&.drawn?

    meld = Meld.new(cards)
    raise ArgumentError, "Invalid meld" unless meld.valid?

    current_player.hand.remove_cards(cards)
    table.add_meld(meld)
    meld
  end

  def layoff(cards, target_meld: nil)
    raise TurnError, "Must draw first" unless current_turn&.drawn?

    success = table.layoff(cards, target_meld: target_meld)
    return false unless success

    current_player.hand.remove_cards(Array(cards))
    true
  end

  private

  def start_turn
    @current_turn = Turn.new(
      player: current_player,
      deck: deck,
      discard_pile: discard_pile
    )
  end

  def ensure_turn_complete!
    raise TurnError, "Turn not complete" unless current_turn.complete?
  end

  def validate_players!
    return if players.size.between?(2, 4)
    raise ArgumentError, "Rummy 500 requires 2 to 4 players"
  end

  def deal_cards
    cards_per_player.times do
      players.each do |player|
        player.hand.add(deck.draw)
      end
    end
  end

  def start_discard_pile
    discard_pile << deck.draw
  end

  def cards_per_player
    players.size == 2 ? 10 : 7
  end
end