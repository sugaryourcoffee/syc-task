# Syctask provides functions for managing tasks in a task list.
module Syctask

  # Evaluator provides different evaluatons for comparing numbers,
  # dates and strings. Also provides methods to check whether a value is part 
  # of a list
  class Evaluator
    # Pattern to match operands <|=|> followed by a number or a single number
    NUMBER_COMPARE_PATTERN = /^(<|=|>)(\d+)|^(\d+)/
    # Pattern to match comma separated values
    CSV_PATTERN = /\w+(?=,)|(?<!<|=|>)\w+$/
    # Pattern to match comma separated numbers
    NUMBER_CSV_PATTERN = /\d+(?=,)|\d+$/
    # Pattern to match a date prepended by <|=|> or a single date
    DATE_COMPARE_PATTERN = /^(<|=|>)(\d{4}-\d{2}-\d{2})|(\d{4}-\d{2}-\d{2})/
    # Pattern to match a date in the form of yyyy-mm-dd
    DATE_PATTERN = /^\d{4}-\d{2}-\d{2}/
    # Pattern that matches anything that is not prepended with <|=|>
    NON_COMPARE_PATTERN = /[^<=>]*/

    # Compares two numbers regarding <|=|>. Returns true if the comparisson
    # succeeds otherwise false. If eather value or pattern is nil false is
    # returned. If value is empty false is returned. 
    def compare_numbers(value, pattern)
      return false if value.nil? or pattern.nil?
      return false if value.class == String and value.empty?
      result = pattern.match(NUMBER_COMPARE_PATTERN)
      return false unless result
      compare(value, result.captures)
    end

    # Compares two dates regarding <|=|>. Returns true if the comparisson
    # succeeds otherwise false. If eather value or pattern is nil false is
    # returned. 
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

    # Compares two values regarding <|=|>. Returns true if the comparisson
    # succeeds otherwise false. If eather value or operand is nil false is
    # returned. 
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

    # Evaluates whether value is part of the provided csv pattern. Returns true
    # if it evaluates to true otherwise false. If value or pattern is nil false
    # is returned. 
    def includes?(value, pattern)
      return false if value.nil? or pattern.nil?
      captures = normalize_ranges(pattern).scan(CSV_PATTERN)
      !captures.find_index(value.to_s).nil?
    end

    # Evaluates if value matches the provided regex. Returns true if a match is
    # found. If value or regex is nil false is returned.
    def matches?(value, regex)
      return false if value.nil? or regex.nil?
      !value.match(Regexp.new(regex, true)).nil?
    end

    # Checks if the pattern contains number ranges then the ranges are 
    # normalized e.g. 1-5 will become 1,2,3,4,5
    def normalize_ranges(pattern)
      if pattern.include? "-"
        pattern.split(',').map do |value|
          if value.include? '-' 
            if value =~ /^\d+-\d+$/
              a, b = value.split('-')
              Array(a..b)
            else
              value
            end
          else 
            value =~ /^\d+$/ ? value.to_i : value
          end
        end.uniq.join(',')
      else
        pattern
      end
    end
  end

end
