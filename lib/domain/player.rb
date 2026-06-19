require "domain/hand"

class Player
  attr_reader :name, :hand
  attr_accessor :score

  def initialize(name, hand: Hand.new, score: 0)
    @name = name
    @hand = hand
    @score = score
  end
end