# Sycstring provides functions for string operations
module Sycstring
  
  # Splits a string to size (chars) less or equal to length
  def split_lines(string, length)
    lines = string.squeeze(" ").split("\n")
    i = 0
    new_lines = []
    new_lines[i] = ""
    lines.each do |line|
      line.squeeze(" ").split.each do |w|
        if new_lines[i].length + w.length < length
          new_lines[i] += "#{w} "
        else
          i += 1
          new_lines[i] = "#{w} "
        end
      end
      i += 1
      new_lines[i] = ""
    end
    text = ""
    new_lines.each {|l| text << "#{l}\n"}
    text.chomp
  end

end
