class MetropolisMethod
  def self.calculate(function, max_x, prev_x)
    r1 = rand(0.0..1.0)
    r2 = rand(0.0..1.0)
    t = (1.0/3.0) * max_x
    x1 = prev_x + t * (-1.0 + 2.0 * r1)

    if x1 < 0 || x1 > max_x
      return prev_x
    end

    alpha = function.call(x1) / function.call(prev_x)

    if alpha >= 1.0 || alpha > r2
      return x1
    end

    prev_x
  end
end