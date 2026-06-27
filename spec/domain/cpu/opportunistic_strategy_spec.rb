require "domain/cpu/opportunistic_strategy"
require "domain/hand"
require "domain/card"
require "domain/table"
require "domain/meld"
require "domain/player"

RSpec.describe OpportunisticStrategy do
  let(:strategy) { described_class.new }

  def card(rank, suit)
    Card.new(rank, suit)
  end

  def hand(*cards)
    Hand.new(cards)
  end

  let(:table) { Table.new }

  describe "#choose_draw" do
    context "when no card in the discard pile completes a meld with the current hand" do
      it "returns nil" do
        current_hand = hand(card("2", "♠"), card("5", "♥"), card("9", "♦"))
        discard_pile = [card("K", "♣")]

        expect(strategy.choose_draw(current_hand, discard_pile)).to be_nil
      end

      it "returns nil when the discard pile is empty" do
        current_hand = hand(card("7", "♠"), card("7", "♥"))

        expect(strategy.choose_draw(current_hand, [])).to be_nil
      end
    end

    context "when a card in the discard pile completes a meld with the current hand" do
      it "returns that card as the draw target" do
        current_hand = hand(card("7", "♠"), card("7", "♥"))
        discard_pile = [card("3", "♦"), card("7", "♦")]

        expect(strategy.choose_draw(current_hand, discard_pile)).to eq(card("7", "♦"))
      end

      it "targets the highest card in the pile to minimise how many cards are scooped" do
        current_hand = hand(card("7", "♠"), card("7", "♥"))
        discard_pile = [card("7", "♦"), card("3", "♣"), card("7", "♣")]

        expect(strategy.choose_draw(current_hand, discard_pile)).to eq(card("7", "♣"))
      end

      it "includes scooped cards when evaluating whether a meld is possible" do
        current_hand = hand(card("7", "♠"), card("7", "♥"))
        discard_pile = [card("3", "♦"), card("2", "♣"), card("7", "♦")]

        expect(strategy.choose_draw(current_hand, discard_pile)).to eq(card("7", "♦"))
      end
    end
  end

  describe "#choose_melds" do
    context "when the hand contains no valid melds" do
      it "returns an empty array" do
        current_hand = hand(card("2", "♠"), card("5", "♥"), card("9", "♦"))

        expect(strategy.choose_melds(current_hand, table)).to be_empty
      end
    end

    context "when the hand contains valid melds" do
      it "returns a valid set" do
        current_hand = hand(card("7", "♠"), card("7", "♥"), card("7", "♦"))

        result = strategy.choose_melds(current_hand, table)

        expect(result.size).to eq(1)
        expect(Meld.new(result.first)).to be_valid
      end

      it "returns a valid run" do
        current_hand = hand(card("4", "♠"), card("5", "♠"), card("6", "♠"))

        result = strategy.choose_melds(current_hand, table)

        expect(result.size).to eq(1)
        expect(Meld.new(result.first)).to be_valid
      end

      it "returns all valid melds when the hand contains more than one" do
        current_hand = hand(
          card("7", "♠"), card("7", "♥"), card("7", "♦"),
          card("4", "♣"), card("5", "♣"), card("6", "♣")
        )

        expect(strategy.choose_melds(current_hand, table).size).to eq(2)
      end

      it "never assigns the same card to more than one meld" do
        current_hand = hand(card("7", "♠"), card("7", "♥"), card("7", "♦"))

        result = strategy.choose_melds(current_hand, table)
        all_cards = result.flatten

        expect(all_cards.uniq.size).to eq(all_cards.size)
      end
    end
  end

  describe "#choose_layoffs" do
    context "when no cards in hand can extend a meld on the table" do
      it "returns an empty array" do
        current_hand = hand(card("2", "♠"), card("K", "♥"))
        meld = Meld.new([card("7", "♠"), card("7", "♥"), card("7", "♦")])
        table.add_meld(meld, player: Player.new("Linnie"))

        expect(strategy.choose_layoffs(current_hand, table)).to be_empty
      end

      it "returns an empty array when the table has no melds" do
        current_hand = hand(card("7", "♣"))

        expect(strategy.choose_layoffs(current_hand, table)).to be_empty
      end
    end

    context "when a card in hand can extend a meld on the table" do
      it "returns the card and its target meld when it extends a set" do
        current_hand = hand(card("7", "♣"))
        meld = Meld.new([card("7", "♠"), card("7", "♥"), card("7", "♦")])
        table.add_meld(meld, player: Player.new("Linnie"))

        result = strategy.choose_layoffs(current_hand, table)

        expect(result.size).to eq(1)
        expect(result.first[:cards]).to include(card("7", "♣"))
        expect(result.first[:target_meld]).to eq(meld)
      end

      it "returns the card and its target meld when it extends a run" do
        current_hand = hand(card("7", "♠"))
        meld = Meld.new([card("4", "♠"), card("5", "♠"), card("6", "♠")])
        table.add_meld(meld, player: Player.new("Linnie"))

        result = strategy.choose_layoffs(current_hand, table)

        expect(result.size).to eq(1)
        expect(result.first[:cards]).to include(card("7", "♠"))
      end

      it "never assigns the same card to more than one layoff" do
        current_hand = hand(card("8", "♣"))
        meld1 = Meld.new([card("8", "♠"), card("8", "♥"), card("8", "♦")])
        meld2 = Meld.new([card("5", "♣"), card("6", "♣"), card("7", "♣")])
        table.add_meld(meld1, player: Player.new("Linnie"))
        table.add_meld(meld2, player: Player.new("Linnie"))

        expect(strategy.choose_layoffs(current_hand, table).size).to eq(1)
      end
    end
  end

  describe "#choose_discard" do
    context "when no cards were picked up from the discard pile this turn" do
      it "discards the highest value card in hand" do
        current_hand = hand(card("2", "♠"), card("A", "♥"), card("7", "♦"))

        expect(strategy.choose_discard(current_hand, nil)).to eq(card("A", "♥"))
      end

      it "prefers discarding a face card over a number card" do
        current_hand = hand(card("2", "♠"), card("K", "♥"), card("7", "♦"))

        expect(strategy.choose_discard(current_hand, nil)).to eq(card("K", "♥"))
      end
    end

    context "when cards were picked up from the discard pile this turn" do
      it "does not discard the card the player targeted from the discard pile" do
        targeted_card = card("A", "♥")
        current_hand = hand(targeted_card, card("7", "♦"), card("2", "♠"))

        result = strategy.choose_discard(current_hand, [targeted_card])

        expect(result).not_to eq(targeted_card)
        expect(result).to eq(card("7", "♦"))
      end

      it "does not discard any card scooped from above the target in the discard pile" do
        targeted_card = card("7", "♣")
        scooped_card = card("A", "♥")
        current_hand = hand(targeted_card, scooped_card, card("2", "♠"))

        result = strategy.choose_discard(current_hand, [targeted_card, scooped_card])

        expect(result).to eq(card("2", "♠"))
      end
    end
  end
end