require "domain/round"
require "domain/player"
require "domain/card"
require "domain/deck"
require "domain/table"
require "domain/turn"

RSpec.describe Round do
  def player(name)
    Player.new(name)
  end

  let(:players) { [player("Linnie"), player("Jake")] }

  def started_round(players = self.players)
    round = Round.new(players)
    round.start
    round
  end

  describe "#initialize" do
    it "sets up core aggregates" do
      round = Round.new(players)

      expect(round.players).to eq(players)
      expect(round.deck).to be_a(Deck)
      expect(round.table).to be_a(Table)
      expect(round.discard_pile).to eq([])
    end
  end

  describe "#start" do
    it "deals correct number of cards based on player count" do
      round = started_round

      expect(players.map { |p| p.hand.size }).to eq([10, 10])
    end

    it "uses 7 cards for 3+ players" do
      players = [player("A"), player("B"), player("C")]
      round = started_round(players)

      expect(players.map { |p| p.hand.size }).to eq([7, 7, 7])
    end

    it "initializes discard pile with exactly one card" do
      round = started_round

      expect(round.discard_pile.size).to eq(1)
      expect(round.discard_pile.first).to be_a(Card)
    end

    it "consumes cards from deck during deal" do
      round = Round.new(players)

      expect {
        round.start
      }.to change { round.deck.size }.by(-21)
    end
  end

  describe "#current_player" do
    it "tracks turn order" do
      round = started_round

      expect(round.current_player).to eq(players.first)
    end
  end

  describe "#end_turn" do
    it "rotates turn order deterministically" do
      round = started_round

      expect {
        round.end_turn
      }.to change { round.current_player }
        .from(players.first)
        .to(players.last)
    end

    it "resets turn after completion" do
      round = started_round

      first_turn = round.current_turn
      round.end_turn

      expect(round.current_turn).not_to eq(first_turn)
    end

    it "assigns the new turn to the next player" do
      round = started_round

      round.end_turn

      expect(round.current_turn.player).to eq(players.last)
    end
  end

  describe "#current_turn" do
    it "builds a Turn object for the current player" do
      round = started_round

      expect(round.current_turn).to be_a(Turn)
      expect(round.current_turn.player).to eq(players.first)
    end

    it "persists turn state across actions" do
      round = started_round

      round.current_turn.draw_from_deck

      expect(round.current_turn.drawn?).to eq(true)
    end
  end

  describe "#play_meld" do
    let(:round) { started_round }

    let(:meld_cards) do
      [
        Card.new("7", "♠"),
        Card.new("7", "♥"),
        Card.new("7", "♦")
      ]
    end

    before do
      round.current_turn.draw_from_deck

      meld_cards.each do |card|
        round.current_player.hand.add(card)
      end
    end

    it "adds a meld to the table" do
      expect {
        round.play_meld(meld_cards)
      }.to change { round.table.size }.by(1)
    end

    it "removes melded cards from the current player's hand" do
      round.play_meld(meld_cards)

      meld_cards.each do |card|
        expect(round.current_player.hand.cards)
          .not_to include(card)
      end
    end

    it "stores the meld on the table" do
      round.play_meld(meld_cards)

      expect(round.table.melds.first.cards)
        .to contain_exactly(*meld_cards)
    end

    it "rejects invalid melds" do
      invalid_cards = [
        Card.new("7", "♠"),
        Card.new("8", "♥"),
        Card.new("9", "♦")
      ]

      invalid_cards.each do |card|
        round.current_player.hand.add(card)
      end

      expect {
        round.play_meld(invalid_cards)
      }.to raise_error(
        ArgumentError,
        "Invalid meld"
      )
    end
  end

  describe "#layoff" do
    let(:round) { started_round }

    let(:base_meld) do
      [
        Card.new("7", "♠"),
        Card.new("7", "♥"),
        Card.new("7", "♦")
      ]
    end

    let(:layoff_card) { Card.new("7", "♣") }

    before do
      round.current_turn.draw_from_deck

      base_meld.each do |card|
        round.current_player.hand.add(card)
      end

      round.play_meld(base_meld)
      round.current_player.hand.add(layoff_card)
    end

    it "adds card to an existing meld via table" do
      expect {
        round.layoff([layoff_card])
      }.to change { round.table.melds.first.cards.size }.by(1)
    end

    it "removes card from player's hand when successful" do
      round.layoff([layoff_card])

      expect(round.current_player.hand.cards)
        .not_to include(layoff_card)
    end

    it "returns true when successful" do
      expect(round.layoff([layoff_card])).to eq(true)
    end

    it "returns false when invalid" do
      bad_card = Card.new("2", "♠")
      round.current_player.hand.add(bad_card)

      expect(round.layoff([bad_card])).to eq(false)
    end
  end

  describe "turn flow" do
    let(:round) { started_round }

    let(:meld_cards) do
      [
        Card.new("7", "♠"),
        Card.new("7", "♥"),
        Card.new("7", "♦")
      ]
    end

    before do
      meld_cards.each do |card|
        round.current_player.hand.add(card)
      end
    end

    it "does not allow melding before drawing" do
      expect {
        round.play_meld(meld_cards)
      }.to raise_error(TurnError, "Must draw first")
    end
  end

  describe "player rules" do
    it "rejects < 2 players" do
      expect {
        Round.new([player("A")]).start
      }.to raise_error(ArgumentError)
    end

    it "rejects > 4 players" do
      players = [
        player("A"), player("B"),
        player("C"), player("D"),
        player("E")
      ]

      expect {
        Round.new(players).start
      }.to raise_error(ArgumentError)
    end
  end
end