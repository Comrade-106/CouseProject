class Generator
  def initialize(a, b, step, generation_count)
    @a = a
    @b = b
    @generation_count = generation_count
    @step = step
  end

  def get_total_generations_count
    ((@b.to_f - @a.to_f) / @step) * @generation_count
  end

  def generate(method)
    frequencies = Hash.new
    sum = 0
    sum_squares = 0

    ((@a + @step)..@b).step(@step).each do |currentStep|
      current_success_method_results = 0
      previous_step = currentStep - @step

      (0..@generation_count).each do
        method_result = method.call
        sum += method_result
        sum_squares += method_result**2

        if method_result > previous_step and method_result <= currentStep
          current_success_method_results += 1
        end
      end

      frequencies.store(currentStep.round(2), current_success_method_results.to_f / @generation_count)
    end

    {
      'frequencies' => frequencies,
      'sum' => sum,
      'sum_squares' => sum_squares,
    }
  end
end