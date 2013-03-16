require 'io/wait'

# Module Sycutil contains functions related to the Console that is helpers
# for user input
module Sycutil
  
  # Console provides functions for user input
  class Console
    
    # Listens on Ctrl-C and exits the application
    Signal.trap("INT") do
      puts "-> program terminated by user"
      exit
    end

    # Listens for key presses and returns the pressed key without pressing
    # return
    #
    # :call-seq:
    #   char_if_pressed
    def char_if_pressed
      begin
        system("stty raw -echo")
        c = nil
        if $stdin.ready?
            c = $stdin.getc
        end
        c.chr if c
      ensure
        system "stty -raw echo"
      end
    end

    # Prompts the user for input.
    #
    # :call-seq:
    #   prompt(choice_line) -> char
    #
    # choice_line is the prompt string. If the prompt string contains a (x)
    # sequence x is a valid choice the is relized when pressed and returned.
    def prompt(choice_line)
      pattern = /(?<=\()./
      choices = choice_line.scan(pattern)

      choice = nil

      while choices.find_index(choice).nil?
        print choice_line 
        choice = nil
        choice = char_if_pressed while choice == nil
        sleep 0.1
        puts
      end

      choice
    end

  end

end
