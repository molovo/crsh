require "fancyline"
require "crayon"
require "./crsh/*"

module Crsh
  @@shell = Shell.new

  def self.shell
    @@shell
  end

  puts "Press Ctrl-D to quit."

  @@shell.fancy.actions.set Fancyline::Key::Control::CtrlH do |ctx|
    if command = Input.get_command(ctx) # Figure out the current command
      system("man #{command}")          # And open the man-page of it
    end
  end

  @@shell.fancy.sub_info.add do |ctx, yielder|
    lines = yielder.call(ctx) # First run the next part of the middleware chain

    str = Input.get_command(ctx)
    if str.nil?
      next lines
    end

    if help = @@shell.state.help_cache[str]?
      lines << help.colorize.dark_gray.to_s
      next lines
    end

    if als = @@shell.alias str
      line = "alias #{str} => #{als}"
      @@shell.state.help_cache[str] = line
      lines << line.colorize.dark_gray.to_s
      next lines
    end

    if command = @@shell.builtin str # Grab the command
      line = "builtin #{command.name} -- #{command.description}"
      @@shell.state.help_cache[str] = line
      lines << line.colorize.dark_gray.to_s
      next lines
    end

    if @@shell.manpath.has? str
      manpage = `man #{str} 2>/dev/null | head -10`
      manpage.lines.each_cons(2) do |parts|
        if parts.first === "NNAAMMEE"
          line = "command #{parts.last.strip}"
          @@shell.state.help_cache[str] = line
          lines << line.colorize.dark_gray.to_s
          next lines
        end
      end
    end

    lines << "" # Clear the line as nothing matched
    lines
  end

  @@shell.fancy.autocomplete.add do |ctx, range, word, yielder|
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
      @@shell.fancy.history.load io  # And load it
    end
  end

  @@shell.start

  File.open(HISTFILE, "w") do |io| # So open it writable
    @@shell.fancy.history.save io  # And save.  That's it.
  end
end
