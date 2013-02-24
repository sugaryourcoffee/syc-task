module Syctask

  class Evaluator
    NUMBER_COMPARE_PATTERN = /^(<|=|>)(\d+)|^(\d+)/
    CSV_PATTERN = /\w+(?=,)|(?<!<|=|>)\w+$/
    NUMBER_CSV_PATTERN = /\d+(?=,)|\d+$/
    DATE_COMPARE_PATTERN = /^(<|=|>)(\d{4}-\d{2}-\d{2})|(\d{4}-\d{2}-\d{2})/
    DATE_PATTERN = /^\d{4}-\d{2}-\d{2}/
    NON_COMPARE_PATTERN = /[^<=>]*/

    def compare_numbers(value, pattern)
      return false if value.nil? or pattern.nil?
      return false if value.class == String and value.empty?
      result = pattern.match(NUMBER_COMPARE_PATTERN)
      return false unless result
      compare(value, result.captures)
    end

    def compare_dates(value, pattern)
      return false if value.nil? or pattern.nil?
      result = pattern.match(DATE_COMPARE_PATTERN)
      return false unless result
      value = "'#{value}'"
      captures = result.captures.collect! do |c| 
        c and c.match(DATE_PATTERN) ? "'#{c}'" : c
      end
      compare(value, captures)
    end

    def compare(value, operands)

      if operands[2]
        operands[0] = "=="
        operands[1] = operands[2]
      elsif operands[0] == "="
        operands[0] = "=="
      end

      expression = "#{value} #{operands[0]} #{operands[1]}"
      eval(expression) 
    end

    def includes?(value, pattern)
      return false if value.nil? or pattern.nil?
      captures = pattern.scan(CSV_PATTERN)
      !captures.find_index(value.to_s).nil?
    end

    def matches?(value, regex)
      return false if value.nil? or regex.nil?
      !value.match(Regexp.new(regex, true)).nil?
    end

  end

end
