require "./builtins/*"

module Crsh
  class Call
    @@builtins = {
      "source" => Builtins::Source,
    }

    def initialize(line : String)
      command = get_command line

      if @@builtins.has_key? command
        args = get_args line
        @@builtins[command].call args
        return
      end

      system(line)
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
