require "domain/table"
require "domain/meld"
require "domain/card"

RSpec.describe Table do
  def card(rank, suit)
    Card.new(rank, suit)
  end

  def set_meld
    Meld.new([
      card("7", "♠"),
      card("7", "♥"),
      card("7", "♦")
    ])
  end

  def run_meld
    Meld.new([
      card("4", "♠"),
      card("5", "♠"),
      card("6", "♠")
    ])
  end

  def invalid_meld
    Meld.new([
      card("7", "♠"),
      card("8", "♥"),
      card("9", "♦")
    ])
  end

  describe "#add_meld" do
    it "stores valid melds" do
      table = Table.new
      table.add_meld(set_meld)

      expect(table.size).to eq(1)
    end

    it "rejects invalid melds" do
      table = Table.new

      expect {
        table.add_meld(invalid_meld)
      }.to raise_error(ArgumentError)
    end

    it "does not allow external mutation of stored melds" do
      table = Table.new

      meld = set_meld
      table.add_meld(meld)

      expect {
        meld.cards << card("7", "♣")
      }.not_to change { table.melds.first.cards.size }
    end
  end

  describe "#layoff" do
    it "adds multiple cards to a run" do
      table = Table.new
      table.add_meld(run_meld)

      result = table.layoff([
        card("7", "♠"),
        card("8", "♠")
      ])

      expect(result).to eq(true)

      ranks = table.melds.first.cards.map(&:rank)
      expect(ranks).to eq(["4", "5", "6", "7", "8"])
    end

    it "adds multiple cards to a set" do
      table = Table.new

      set = Meld.new([
        card("9", "♦"),
        card("9", "♥"),
        card("9", "♠")
      ])

      table.add_meld(set)

      result = table.layoff([
        card("9", "♣")
      ])

      expect(result).to eq(true)
      expect(table.melds.first.cards.size).to eq(4)
    end

    it "rejects invalid multi-card layoff" do
      table = Table.new
      table.add_meld(run_meld)

      result = table.layoff([
        card("9", "♠"),
        card("10", "♠")
      ])

      expect(result).to eq(false)
    end

    it "still works with single card" do
      table = Table.new
      table.add_meld(run_meld)

      result = table.layoff(card("7", "♠"))

      expect(result).to eq(true)
    end

    it "rejects empty layoff" do
      table = Table.new
      table.add_meld(set_meld)

      expect(table.layoff([])).to eq(false)
    end
  end

  describe "#melds immutability" do
    it "does not allow external modification of internal melds" do
      table = Table.new
      table.add_meld(set_meld)

      external = table.melds
      external << set_meld

      expect(table.melds.size).to eq(1)
    end
  end

  describe "#empty?" do
    it "returns true when no melds exist" do
      expect(Table.new).to be_empty
    end
  end
end