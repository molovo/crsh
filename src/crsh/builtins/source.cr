require "../command"

module Crsh::Builtins
  class Source < Command
    getter name = "source"
    getter description = "load an external script"

    def call(args : Array(String), shell : Shell)
      puts "Tada!"
    end
  end
end
