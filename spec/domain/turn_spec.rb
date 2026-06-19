require "domain/turn"
require "domain/player"

RSpec.describe Turn do
  let(:player) { Player.new("Linnie") }
  let(:deck) { double("deck") }
  let(:discard_pile) { [] }

  it "is initialized with dependencies explicitly" do
    turn = Turn.new(
      player: player,
      deck: deck,
      discard_pile: discard_pile
    )

    expect(turn.player).to eq(player)
    expect(turn.deck).to eq(deck)
    expect(turn.discard_pile).to eq(discard_pile)
  end
end