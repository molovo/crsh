module Crsh
  class SuggestionProvider
    def initialize(@shell : Shell)
      return unless @shell.config.autosuggestions

      @shell.fancy.display.add do |ctx, line, yielder|
        stripped = line.colorize.toggle(false).to_s
        yielder.call ctx, line unless stripped

        suggestion = get_suggestion stripped

        line = "#{line}#{suggestion.colorize.dark_gray.to_s.lstrip(stripped)}"
        yielder.call ctx, line
      end
    end

    def get_suggestion(line : String) : String
      @shell.fancy.history.lines.reverse.each do |suggestion|
        if suggestion.starts_with? line
          return suggestion
        end
      end

      line
    end
  end
end
