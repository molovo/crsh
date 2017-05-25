require "../command"

module Crsh::Builtins
  class Config < Command
    getter name = "config"
    getter description = "show configuration values for the shell"

    def call(args : Array(String), shell : Shell)
      case args.size
      when 0
        raise "Must provide a key"
      else
        key = args.first.to_s
      end

      puts shell.config.get(key)
    end
  end
end
