# frozen_string_literal: true

class Numeric
  def percent
    to_f / 100.0
  end

  def percent_of(n)
    to_f / n * 100.0
  end
end
