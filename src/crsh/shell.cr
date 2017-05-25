module Crsh
  class Shell
    BUILTINS = {
      "cd"     => Builtins::Cd.new,
      "config" => Builtins::Config.new,
      "set"    => Builtins::Set.new,
      "source" => Builtins::Source.new,
    }

    getter! config : Config?
    getter! highlighter : Highlighter?
    getter! suggestion_provider : SuggestionProvider?
    getter! prompt : Prompt?

    getter path = Path.new
    getter manpath = Manpath.new
    getter state = State.new
    getter fancy = Fancyline.new

    getter aliases = {
      "gws" => "git status --short",
    }

    def initialize
      @config = Config.new(self)
      @prompt = Prompt.new(self)
      @highlighter = Highlighter.new(self)
      @suggestion_provider = SuggestionProvider.new(self)
    end

    def alias(name : String?) : String?
      nil if name.nil?
      @aliases[name]?
    end

    def builtin(name : String?) : Command?
      nil if name.nil?
      BUILTINS[name]?
    end

    def start
      prompt = @prompt
      raise "Uh Oh! We've lost our prompt" if prompt.nil?

      begin # Get rid of stacktrace on ^C
        while input = @fancy.readline(prompt.print)
          Call.new(input, self)
        end
      rescue err : Fancyline::Interrupt
        puts "Bye."
      end
    end
  end
end
