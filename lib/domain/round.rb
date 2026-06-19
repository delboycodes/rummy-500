require "domain/deck"
require "domain/table"

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