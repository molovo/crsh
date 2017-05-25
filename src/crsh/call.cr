require "./builtins/*"

module Crsh
  # A `Call` instance is create when the prompt is submitted, to decide what to
  # do with the user input. It tries to find a match for the given command by
  # searching in the following order:
  # * aliases
  # * crsh builtin commands
  # * the path
  # * files in current directory
  class Call
    def initialize(line : String, @shell : Shell)
      command = get_command line

      # Search an alias which matches the command passed.
      # If one is found, we expand it to get the full command, and continue
      # searching with the expanded line
      if als = @shell.alias command # TODO: implement aliases
        line = "#{als} #{get_args(line).join ' '}"
        command = get_command line
      end

      # Search for a builtin command which matches the command passed
      if builtin = @shell.builtin command
        args = get_args line
        builtin.call args, @shell
        return
      end

      # Search the path for a command, and if found, proxy the call to SH
      if @shell.path.has? command
        system(line)
        return
      end

      puts "Command not found".colorize(:red)
    end

    def get_command(line : String) : String?
      line.split.first?
    end

    def get_args(line : String) : Array(String)?
      args = line.split
      args.shift
      args
    end
  end
end
