require "domain/meld"

class Table
  def initialize
    @melds_by_player = Hash.new { |hash, key| hash[key] = [] }
  end

  def add_meld(meld, player:)
    raise ArgumentError, "Invalid meld" unless meld.valid?

    @melds_by_player[player] << clone_meld(meld)
  end

  def layoff(input_cards, target_meld: nil)
    cards = Array(input_cards)
    return false if cards.empty?

    target_meld ||= find_layoff_target(cards)
    return false unless target_meld

    owner = find_owner_of(target_meld)
    return false unless owner

    extended_meld = Meld.new(target_meld.cards + cards)
    return false unless extended_meld.valid?

    update_player_meld(owner, old_meld: target_meld, new_meld: extended_meld)
    true
  end

  def melds_for(player)
    @melds_by_player[player].dup
  end

  def all_melds
    @melds_by_player.values.flatten
  end

  def size
    all_melds.size
  end

  def empty?
    all_melds.empty?
  end

  private

  def find_layoff_target(cards)
    all_melds.find do |meld|
      Meld.new(meld.cards + cards).valid?
    end
  end

  def find_owner_of(meld)
    @melds_by_player.keys.find do |player|
      @melds_by_player[player].include?(meld)
    end
  end

  def update_player_meld(player, old_meld:, new_meld:)
    @melds_by_player[player].delete(old_meld)
    @melds_by_player[player] << clone_meld(new_meld)
  end

  def clone_meld(meld)
    Meld.new(meld.cards)
  end
end