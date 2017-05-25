require "../command"

module Crsh::Builtins
  class Set < Command
    getter name = "set"
    getter description = "set configuration values for the shell"

    def call(args : Array(String), shell : Shell)
      case args.size
      when 0
        raise "Must provide a key"
      when 1
        raise "Must provide a value"
      else
        key = args.first.to_s
        args.delete key
        value = args

        if value.size === 1
          value = value.first.to_s
        end
      end

      shell.config.set key, value
    end
  end
end
