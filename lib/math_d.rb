class MathD
  def factorial(n)
    # return 1 if n == 1 || n == 0
    #
    # factorial(n - 1) * n
    res = 1
    (1...n + 1).each { |i|
      res *= i
    }
    res
  end

  def comb(n, k)
    factorial(n)/factorial(k)/factorial(n-k)
  end

  def bates_pdf(x, n, a, b)
    sum = 0
    k = 0
    x_0 = (x-a)/(b-a)
    while k <= n*x do
      term = comb(n, k)*((n*x_0-k)**(n-1))

      term = -term if k%2==1

      sum += term
      k += 1
    end
    sum*n/factorial(n-1)
  end

  def get_pdf_distribution(n, a, b)
    points = Hash.new
    count = 1000
    dt = (b-a)/count
    step = (a..b).step(dt).to_a
    step.each { |t|
      value = bates_pdf(t, n, a, b)
      points.store(t, value)
    }
    points
  end

  def get_expected_value_theory(a, b)
    0.5 * (a + b)
  end

  def get_expected_value(generation_count, generation_sum)
    generation_sum / generation_count
  end

  def get_dispersion_theory(n, a, b)
    1.0/(12.0*n) * (b-a)**2
  end

  def get_dispersion(generation_count, sum, squares_sum)
    mean = get_expected_value(generation_count, sum)
    (squares_sum - (mean * mean * generation_count)) / (generation_count - 1)
  end

  def maximum_value(count, n, a, b)
    max = bates_pdf(0.0, n, a, b)

    i = 1
    while i <= count do
      x = (1.0 - 0.0).to_f / count * i
      f = bates_pdf(x, n, a, b)

      max = f if f > max

      i += 1
    end

    return max
  end

  def get_deviation(generation_count, sum, squares_sum)
    variance = get_dispersion(generation_count, sum, squares_sum)
    Math.sqrt(variance / generation_count)
  end
end
