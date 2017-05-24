module Crsh
  # Provides syntax highlighting for command input
  class Highlighter
    def initialize(@shell : Shell)
      return unless @shell.config.syntax_highlighting

      @shell.fancy.display.add do |ctx, line, yielder|
        line = highlight_commands line
        line = highlight_files line

        yielder.call ctx, line
      end
    end

    def highlight_commands(line : String) : String
      cmd = line.split.first?
      return line if cmd.nil?

      color = nil
      case true
      when @shell.builtin cmd
        color = :magenta
      when @shell.path.has? cmd
        color = :green
      else
        color = :red
      end

      return line if color.nil?

      line.gsub(/^\w+/, &.colorize(color))
          .gsub(/(\|\s*)(\w+)/) { "#{$1}#{$2.colorize(color)}" }
    end

    def highlight_files(line : String) : String
      line.split.each do |word|
        if File.exists?(File.expand_path(word))
          line = line.gsub(word, &.colorize(:blue))
        end

        if Dir.exists?(File.expand_path(word))
          line = line.gsub(word, &.colorize(:blue).mode(:underline))
        end
      end

      line
    end

    # @shell.fancy.display.add do |ctx, line, yielder|
    #   # We underline command names
    #   line = line.gsub(/^\w+/, &.colorize.mode(:underline))
    #   line = line.gsub(/(\|\s*)(\w+)/) do
    #     "#{$1}#{$2.colorize.mode(:underline)}"
    #   end

    #   # And turn --arguments green
    #   line = line.gsub(/--?\w+/, &.colorize(:green))

    #   # Then we call the next middleware with the modified line
    #   yielder.call ctx, line
    # end
  end
end
