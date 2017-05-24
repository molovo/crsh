module Crsh
  abstract class Command
    getter name = ""
    getter description = ""

    abstract def call(args : Array(String), shell : Shell)
  end
end
