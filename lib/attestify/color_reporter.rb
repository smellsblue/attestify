require "attestify"

module Attestify
  # Reports results to the console, with color!
  class ColorReporter < Attestify::Reporter
    private

    def puts_failure_header(result, number)
      print color_code(color_for(result))
      super
      print color_code(:reset)
    end

    def puts_failure_detail(failure_detail, number, sub_number)
      print color_code(color_for_detail(failure_detail))
      super
      print color_code(:reset)
    end

    def print_result_code(result)
      print color_code(color_for(result))
      super
      print color_code(:reset)
    end

    def total_tests
      colorize_from_totals(super)
    end

    def total_failures
      colorize_if_positive(super, @total_failures, :red)
    end

    def total_errors
      colorize_if_positive(super, @total_errors, :bold_red)
    end

    def total_skips
      colorize_if_positive(super, @total_skips, :yellow)
    end

    def total_assertions
      colorize_from_totals(super)
    end

    def total_failed_assertions
      colorize_if_positive(super, @total_failed_assertions, :red)
    end

    def colorize_from_totals(text) # rubocop:disable Metrics/MethodLength
      color =
        if @total_errors > 0
          :bold_red
        elsif @total_failures > 0
          :red
        elsif @total_skips > 0
          :yellow
        else
          :green
        end

      colorize(text, color)
    end

    def colorize_if_positive(text, amount, color)
      if amount > 0
        colorize(text, color)
      else
        text
      end
    end

    def colorize(text, color)
      "#{color_code(color)}#{text}#{color_code(:reset)}"
    end

    def color_code(color) # rubocop:disable Metrics/MethodLength
      case color
      when :reset
        "\e[0m"
      when :bold_red
        "\e[1;31m"
      when :red
        "\e[31m"
      when :yellow
        "\e[33m"
      when :green
        "\e[32m"
      end
    end

    def color_for(result) # rubocop:disable Metrics/MethodLength
      if result.skipped?
        :yellow
      elsif result.passed?
        :green
      elsif result.errored?
        :bold_red
      elsif result.failed?
        :red
      else
        :none
      end
    end

    def color_for_detail(failure_detail)
      case failure_detail.type
      when :error
        :bold_red
      when :failure
        :red
      else
        :none
      end
    end
  end
end
