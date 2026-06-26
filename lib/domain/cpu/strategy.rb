class CpuStrategy
  def choose_draw(hand, discard_pile)
    raise NotImplementedError, "#{self.class} must implement choose_draw"
  end

  def choose_melds(hand, table)
    raise NotImplementedError, "#{self.class} must implement choose_melds"
  end

  def choose_layoffs(hand, table)
    raise NotImplementedError, "#{self.class} must implement choose_layoffs"
  end

  def choose_discard(hand, cards_drawn_from_discard)
    raise NotImplementedError, "#{self.class} must implement choose_discard"
  end

  def observe_turn_end(discard_pile, table)
    # stateless strategies ignore this
  end
end