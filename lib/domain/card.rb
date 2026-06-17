class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def value
    return 15 if rank == "A"
    return 10 if ["J", "Q", "K"].include?(rank)
    rank.to_i
  end

  def to_s
    "#{rank}#{suit}"
  end
end