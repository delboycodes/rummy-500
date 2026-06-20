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
  end

  def start
    validate_players!
    deal_cards
    start_discard_pile
  end

  def current_player
    players.first
  end

  def current_turn
    Turn.new(
      player: current_player,
      deck: deck,
      discard_pile: discard_pile
    )
  end

  def end_turn
    players.rotate!
  end

  def play_meld(cards)
    meld = Meld.new(cards)

    raise ArgumentError, "Invalid meld" unless meld.valid?

    current_player.hand.remove_cards(cards)

    table.add_meld(meld)
  end

  def layoff(cards)
    success = table.layoff(cards)

    return false unless success

    current_player.hand.remove_cards(cards)

    true
  end

  private

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