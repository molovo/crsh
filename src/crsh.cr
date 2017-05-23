require "fancyline"
require "crayon"
require "./crsh/*"

module Crsh
  @@output = Crayon::Text.new

  def self.output
    @@output
  end

  fancy = Fancyline.new # Build a shell object
  puts "Press Ctrl-D to quit."

  fancy.display.add do |ctx, line, yielder|
    # We underline command names
    line = line.gsub(/^\w+/, &.colorize.mode(:underline))
    line = line.gsub(/(\|\s*)(\w+)/) do
      "#{$1}#{$2.colorize.mode(:underline)}"
    end

    # And turn --arguments green
    line = line.gsub(/--?\w+/, &.colorize(:green))

    # Then we call the next middleware with the modified line
    yielder.call ctx, line
  end

  fancy.actions.set Fancyline::Key::Control::CtrlH do |ctx|
    if command = Input.get_command(ctx) # Figure out the current command
      system("man #{command}")          # And open the man-page of it
    end
  end

  fancy.sub_info.add do |ctx, yielder|
    lines = yielder.call(ctx) # First run the next part of the middleware chain

    if command = Input.get_command(ctx) # Grab the command
      help_line = `whatis #{command} 2> /dev/null`.lines.first?

      if help_line
        w = `tput cols`.lines.first? || 80
        help_line = help_line[0, w.to_i32] # Limit to screen width
        lines << help_line if help_line    # Display it if we got something
      end
    end

    lines # Return the lines so far
  end

  fancy.autocomplete.add do |ctx, range, word, yielder|
    completions = yielder.call(ctx, range, word)

    # The `word` may not suffice for us here.  It'd be fine however for command
    # name completion.

    # Find the range of the current path name near the cursor.
    prev_char = ctx.editor.line[ctx.editor.cursor - 1]?
    if !word.empty? || {'/', '.'}.includes?(prev_char)
      # Then we try to find where it begins and ends
      arg_begin = ctx.editor.line.rindex(' ', ctx.editor.cursor - 1) || 0
      arg_end = ctx.editor.line.index(' ', arg_begin + 1) || ctx.editor.line.size
      range = (arg_begin + 1)...arg_end

      # And using that range we just built, we can find the path the user entered
      path = ctx.editor.line[range].strip
    end

    # Find suggestions and append them to the completions array.
    Dir["#{path}*"].each do |suggestion|
      base = File.basename(suggestion)
      suggestion += '/' if Dir.exists? suggestion
      completions << Fancyline::Completion.new(range, suggestion, base)
    end

    completions
  end

  HISTFILE = "#{Dir.current}/history.log"

  if File.exists? HISTFILE # Does it exist?
    puts "  Reading history from #{HISTFILE}"
    File.open(HISTFILE, "r") do |io| # Open a handle
      fancy.history.load io          # And load it
    end
  end

  prompt = Prompt.new

  begin # Get rid of stacktrace on ^C
    while input = fancy.readline(prompt.print)
      Call.new(input)
    end
  rescue err : Fancyline::Interrupt
    puts "Bye."
  end

  File.open(HISTFILE, "w") do |io| # So open it writable
    fancy.history.save io          # And save.  That's it.
  end
end
