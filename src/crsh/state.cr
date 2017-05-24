module Crsh
  # A class which provides the global state for the shell session
  class State
    @dir_history = [] of String
    @help_cache = {} of String => String?

    def dir_history
      @dir_history
    end

    def help_cache
      @help_cache
    end
  end
end
