# frozen_string_literal: true

# Syctask provides functions for managing tasks in a task list
module Syctask
  # Holds the version number of syctask
  VERSION = File.exist? ? File.read('.sycersion/version') : '1.0.0'
end
