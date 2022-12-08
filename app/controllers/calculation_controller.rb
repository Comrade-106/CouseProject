require_relative '../../lib/math_d'
require_relative '../../lib/generator'
require_relative '../../lib/neumann_method'
require_relative '../../lib/metropolis_method'

class CalculationController < ApplicationController

  def calculate
    respond_to do |format|
      format.html do
        Point.delete_all
        count = params['N']
        @a = 0.0
        @b = 1.0
        @n = params['n']
        @step = 0.01

        if count && @b && @a && @n
          count = count.to_i
          @b = @b.to_f
          @a = @a.to_f
          @n = @n.to_i
        else
          return
        end

        if count < 1 || @b <= @a
          return
        end

        generator = Generator.new(@a, @b, @step, count * @step)
        total_generations_count = generator.get_total_generations_count
        math_d = MathD.new

        pdf_calculation_lambda = -> (x) { math_d.bates_pdf(x, @n, @a, @b) }
        pdf_mean_value = math_d.get_expected_value_theory(@a, @b)
        pdf_variance_value = math_d.get_dispersion_theory(@n, @a, @b)
        puts "Dispersion = " + pdf_variance_value.to_s
        pdf_maximum_value = math_d.maximum_value(1000, @n, @a, @b)

        neumann_method_lambda = -> () { NeumannMethod.calculate(pdf_calculation_lambda, pdf_maximum_value, @b) }

        previous_x_result = math_d.get_expected_value_theory(@a, @b)
        metropolis_method_lambda = -> () {
          calculation_result = MetropolisMethod.calculate(pdf_calculation_lambda, @b, previous_x_result)
          previous_x_result = calculation_result
          calculation_result
        }

        puts "Generate Neumann"
        neumann_method_data = generator.generate(neumann_method_lambda)
        puts "Generate Metropolis"
        metropolis_method_data = generator.generate(metropolis_method_lambda)

        write_point_to_db(neumann_method_data['frequencies'], "neumann")
        write_point_to_db(metropolis_method_data['frequencies'], "metropolis")

        neumann_method_expected = math_d.get_expected_value(
          total_generations_count,
          neumann_method_data['sum']
        )

        metropolis_method_expected = math_d.get_expected_value(
          total_generations_count,
          metropolis_method_data['sum']
        )

        neumann_method_variance = math_d.get_dispersion(
          total_generations_count,
          neumann_method_data['sum'],
          neumann_method_data['sum_squares'],
          )
        metropolis_method_variance = math_d.get_dispersion(
          total_generations_count,
          metropolis_method_data['sum'],
          metropolis_method_data['sum_squares'],
          )

        puts "Generation PDF distribution"
        pdf_distribution_data = math_d.get_pdf_distribution(@n, @a, @b)
        write_point_to_db(pdf_distribution_data, "pdf_distribution")

        @calculation_result = {
          'options' => {
            'count' => count,
            'n' => @n,
            'a' => @a,
            'b' => @b
          },
          'pdfMaxValue' => pdf_maximum_value,
          'pdfMeanValue' => pdf_mean_value,
          'pdfVarianceValue' => pdf_variance_value,
          'neumannMethod' => neumann_method_data['frequencies'],
          'metropolisMethod' => metropolis_method_data['frequencies'],
          'pdf_distribution_data' => pdf_distribution_data,
          'neumannMethodExpectedValue' => neumann_method_expected,
          'metropolisMethodExpectedValue' => metropolis_method_expected,
          'neumannMethodVariance' => neumann_method_variance,
          'metropolisMethodVariance' => metropolis_method_variance,
        }
      end
    end
  end

  def export
    types = %w[metropolis neumann pdf_distribution]
    count = params['N'].to_i
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      types.each { |type|
        points = Point.where("d_type = '#{type}'")
        write_results_to_xlsx(zos,
                              points,
                              count,
                              type)
      }
    end

    compressed_filestream.rewind
    send_data compressed_filestream.read, filename: 'results.zip'
  end

  private
  def write_results_to_xlsx(zos, points, count, type)
    zos.put_next_entry "#{type}.xlsx"
    zos.print render_to_string(
                layout: false, handlers: [:axlsx], formats: [:xlsx],
                template: "calculation/point",
                locals: {points: points,
                         params: count}
              )
  end

  def write_point_to_db(points, type)
    points.each do |key, value|
      temp = Point.new x: key, y: value, n: 20, d_type: type
      temp.save
    end
  end
end