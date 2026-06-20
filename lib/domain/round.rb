require "domain/deck"
require "domain/table"
require "domain/turn"
require "domain/meld"

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

    reset_turn!
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
    reset_turn!
  end

  def play_meld(cards)
    ensure_turn_drawn!

    meld = Meld.new(cards)
    raise ArgumentError, "Invalid meld" unless meld.valid?

    current_player.hand.remove_cards(cards)
    table.add_meld(meld)
  end

  def layoff(cards)
    ensure_turn_drawn!

    success = table.layoff(cards)
    return false unless success

    current_player.hand.remove_cards(cards)
    true
  end

  private

  def build_turn
    Turn.new(
      player: current_player,
      deck: deck,
      discard_pile: discard_pile
    )
  end

  def reset_turn!
    @current_turn = build_turn
  end

  def ensure_turn_drawn!
    raise TurnError, "Must draw first" unless current_turn.drawn?
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