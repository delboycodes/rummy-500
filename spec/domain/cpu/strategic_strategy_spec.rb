require "domain/cpu/strategic_strategy"
require "domain/hand"
require "domain/card"
require "domain/table"
require "domain/meld"
require "domain/player"

RSpec.describe StrategicStrategy do
  subject(:strategy) { described_class.new }

  let(:table) { Table.new }

  def card(rank, suit)
    Card.new(rank, suit)
  end

  def hand(*cards)
    Hand.new(cards)
  end

  def player(name)
    Player.new(name)
  end

  describe "#observe_turn_end" do
    it "stores the full discard pile state" do
      strategy.observe_turn_end([card("3", "♠"), card("7", "♥")], table)

      expect(strategy.instance_variable_get(:@seen_discards))
        .to contain_exactly(card("3", "♠"), card("7", "♥"))
    end

    it "replaces previous discard state on each update" do
      strategy.observe_turn_end([card("3", "♠")], table)
      strategy.observe_turn_end([card("7", "♥")], table)

      expect(strategy.instance_variable_get(:@seen_discards))
        .to contain_exactly(card("7", "♥"))
    end

    it "stores all cards from opponent melds" do
      meld = Meld.new([card("7", "♠"), card("7", "♥"), card("7", "♦")])
      table.add_meld(meld, player: player("Jake"))

      strategy.observe_turn_end([], table)

      expect(strategy.instance_variable_get(:@opponent_melds))
        .to include(card("7", "♠"), card("7", "♥"), card("7", "♦"))
    end

    it "replaces opponent meld memory on each update" do
      first_table = Table.new
      first_table.add_meld(
        Meld.new([card("7", "♠"), card("7", "♥"), card("7", "♦")]),
        player: player("Jake")
      )

      strategy.observe_turn_end([], first_table)

      second_table = Table.new
      second_table.add_meld(
        Meld.new([card("4", "♣"), card("5", "♣"), card("6", "♣")]),
        player: player("Jake")
      )

      strategy.observe_turn_end([], second_table)

      expect(strategy.instance_variable_get(:@opponent_melds))
        .to include(card("4", "♣"), card("5", "♣"), card("6", "♣"))

      expect(strategy.instance_variable_get(:@opponent_melds))
        .not_to include(card("7", "♠"))
    end
  end

  describe "#choose_discard" do
    context "when avoiding opponent meld extensions" do
      before do
        table.add_meld(
          Meld.new([card("7", "♠"), card("7", "♥"), card("7", "♦")]),
          player: player("Jake")
        )

        strategy.observe_turn_end([], table)
      end

      it "avoids discarding cards matching opponent sets" do
        current_hand = hand(card("7", "♣"), card("2", "♠"))

        expect(strategy.choose_discard(current_hand, nil))
          .to eq(card("2", "♠"))
      end

      it "avoids discarding cards adjacent in suit in opponent runs" do
        run_table = Table.new
        run_table.add_meld(
          Meld.new([card("5", "♣"), card("6", "♣"), card("7", "♣")]),
          player: player("Jake")
        )

        strategy.observe_turn_end([], run_table)

        current_hand = hand(card("8", "♣"), card("2", "♠"))

        expect(strategy.choose_discard(current_hand, nil))
          .to eq(card("2", "♠"))
      end
    end

    context "when discard pile shows repeated ranks" do
      before do
        strategy.observe_turn_end([card("K", "♠"), card("K", "♥")], table)
      end

      it "avoids ranks appearing multiple times in discard pile" do
        current_hand = hand(card("K", "♦"), card("3", "♠"))

        expect(strategy.choose_discard(current_hand, nil))
          .to eq(card("3", "♠"))
      end

      it "allows single occurrence ranks" do
        strategy.observe_turn_end([card("K", "♠")], table)

        current_hand = hand(card("K", "♦"), card("3", "♠"))

        expect(strategy.choose_discard(current_hand, nil))
          .to eq(card("K", "♦"))
      end
    end

    context "when all options are risky" do
      before do
        table.add_meld(
          Meld.new([card("7", "♠"), card("7", "♥"), card("7", "♦")]),
          player: player("Jake")
        )

        strategy.observe_turn_end([], table)
      end

      it "falls back to highest value card" do
        current_hand = hand(card("7", "♣"), card("A", "♠"))

        expect(strategy.choose_discard(current_hand, nil))
          .to eq(card("A", "♠"))
      end
    end

    context "when cards were drawn from discard pile" do
      it "never discards the drawn target card" do
        drawn = card("A", "♥")
        current_hand = hand(drawn, card("3", "♠"))

        expect(strategy.choose_discard(current_hand, [drawn]))
          .to eq(card("3", "♠"))
      end

      it "never discards scooped discard pile cards" do
        target = card("7", "♣")
        scooped = card("A", "♥")

        current_hand = hand(target, scooped, card("2", "♠"))

        expect(strategy.choose_discard(current_hand, [target, scooped]))
          .to eq(card("2", "♠"))
      end
    end

    context "when handling Ace adjacency in runs" do
      it "treats A-2 as sequential in suit" do
        ace = card("A", "♠")
        two = card("2", "♠")

        expect(strategy.send(:sequential_in_suit?, ace, two)).to eq(true)
      end

      it "treats K-A as sequential in suit" do
        king  = card("K", "♠")
        ace   = card("A", "♠")

        expect(strategy.send(:sequential_in_suit?, king, ace)).to eq(true)
      end
    end
  end
end