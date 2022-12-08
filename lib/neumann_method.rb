class NeumannMethod
  def self.calculate(function, max_value, max_x)
    while true
      x = rand(0.0..1.0) * max_x
      y = rand(0.0..1.0) * max_value

      if function.call(x) > y
        return x
      end
    end
  end
end