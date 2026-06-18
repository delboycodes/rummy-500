require "domain/table"
require "domain/meld"
require "domain/card"

RSpec.describe Table do
  def card(rank, suit)
    Card.new(rank, suit)
  end

  def valid_set_meld
    Meld.new([
      card("7", "♠"),
      card("7", "♥"),
      card("7", "♦")
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

      table.add_meld(valid_set_meld)

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

      meld = valid_set_meld
      table.add_meld(meld)

      meld.cards << card("7", "♣")

      expect(table.melds.first.cards.size).to eq(3)
    end
  end

  describe "#melds" do
    it "does not allow external modification of internal melds" do
			table = Table.new
			table.add_meld(valid_set_meld)

			external = table.melds
			external << valid_set_meld

			expect(table.melds.size).to eq(1)
    end
  end

  describe "#empty?" do
    it "returns true when no melds exist" do
      expect(Table.new).to be_empty
    end
  end
end