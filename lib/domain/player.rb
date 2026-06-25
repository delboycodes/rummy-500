require "domain/hand"

class Player
  attr_reader :name
  attr_accessor :hand, :score

  def initialize(name, hand: Hand.new, score: 0)
    @name = name
    @hand = hand
    @score = score
  end
end