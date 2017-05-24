require "./builtins/*"

module Crsh
  class Call
    def initialize(line : String, @shell : Shell)
      command = get_command line

      if builtin = @shell.builtin command
        args = get_args line
        builtin.call args, @shell
        return
      end

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
