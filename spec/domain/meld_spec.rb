require "domain/meld"
require "domain/card"

RSpec.describe Meld do
  def card(rank, suit)
    Card.new(rank, suit)
  end

  describe "sets" do
    it "validates a 3-of-a-kind set" do
      meld = Meld.new([
        card("7", "♠"),
        card("7", "♥"),
        card("7", "♦")
      ])

      expect(meld).to be_valid
    end

    it "validates a 4-of-a-kind set" do
      meld = Meld.new([
        card("9", "♠"),
        card("9", "♥"),
        card("9", "♦"),
        card("9", "♣")
      ])

      expect(meld).to be_valid
    end

    it "rejects sets with less than 3 cards" do
      meld = Meld.new([
        card("7", "♠"),
        card("7", "♥")
      ])

      expect(meld).not_to be_valid
    end

    it "rejects sets with more than 4 cards" do
      meld = Meld.new([
        card("7", "♠"),
        card("7", "♥"),
        card("7", "♦"),
        card("7", "♣"),
        card("7", "♠")
      ])

      expect(meld).not_to be_valid
    end

    it "rejects mixed ranks in a set" do
      meld = Meld.new([
        card("7", "♠"),
        card("7", "♥"),
        card("8", "♦")
      ])

      expect(meld).not_to be_valid
    end
  end

  describe "runs" do
    it "validates a basic run" do
      meld = Meld.new([
        card("4", "♠"),
        card("5", "♠"),
        card("6", "♠")
      ])

      expect(meld).to be_valid
    end

    it "validates an unsorted run" do
      meld = Meld.new([
        card("6", "♠"),
        card("4", "♠"),
        card("5", "♠")
      ])

      expect(meld).to be_valid
    end

    it "validates runs longer than 3 cards" do
      meld = Meld.new([
        card("4", "♠"),
        card("5", "♠"),
        card("6", "♠"),
        card("7", "♠")
      ])

      expect(meld).to be_valid
    end

    it "validates ace-low runs (A-2-3)" do
      meld = Meld.new([
        card("A", "♠"),
        card("2", "♠"),
        card("3", "♠")
      ])

      expect(meld).to be_valid
    end

    it "validates ace-high runs (Q-K-A)" do
      meld = Meld.new([
        card("Q", "♠"),
        card("K", "♠"),
        card("A", "♠")
      ])

      expect(meld).to be_valid
    end

    it "rejects runs shorter than 3 cards" do
      meld = Meld.new([
        card("4", "♠"),
        card("5", "♠")
      ])

      expect(meld).not_to be_valid
    end

    it "rejects runs with different suits" do
      meld = Meld.new([
        card("4", "♠"),
        card("5", "♥"),
        card("6", "♠")
      ])

      expect(meld).not_to be_valid
    end

    it "rejects runs with gaps in sequence" do
      meld = Meld.new([
        card("4", "♠"),
        card("6", "♠"),
        card("7", "♠")
      ])

      expect(meld).not_to be_valid
    end

    it "rejects duplicate ranks inside a run" do
      meld = Meld.new([
        card("4", "♠"),
        card("5", "♠"),
        card("5", "♠"),
        card("6", "♠")
      ])

      expect(meld).not_to be_valid
    end

    it "rejects K-A-2 wraparound runs" do
      meld = Meld.new([
        card("K", "♠"),
        card("A", "♠"),
        card("2", "♠")
      ])

      expect(meld).not_to be_valid
    end

    it "rejects non-consecutive Ace usage (A in middle incorrectly)" do
      meld = Meld.new([
        card("A", "♠"),
        card("3", "♠"),
        card("4", "♠")
      ])

      expect(meld).not_to be_valid
    end
  end

  describe "edge cases" do
    it "rejects empty melds" do
      expect(Meld.new([])).not_to be_valid
    end

    it "rejects single card melds" do
      expect(Meld.new([card("7", "♠")])).not_to be_valid
    end

    it "rejects mixed set/run ambiguity (same cards cannot satisfy both incorrectly)" do
      meld = Meld.new([
        card("7", "♠"),
        card("7", "♥"),
        card("7", "♦"),
        card("8", "♠")
      ])

      expect(meld).not_to be_valid
    end
  end
end