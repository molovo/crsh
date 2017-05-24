require "../command"

module Crsh::Builtins
  class Cd < Command
    getter name = "cd"
    getter description = "change the current directory"

    def call(args : Array(String), shell : Shell)
      case args.size
      when 0
        call "~", shell
      when 1
        call args.first, shell
      when 2
        call Dir.current.sub(args.first, args.last), shell
      end
    end

    def call(path : String, shell : Shell)
      case path
      when "~"
        path = ENV["HOME"]
      when "-"
        path = shell.state.dir_history.last? || ENV["HOME"]
      end

      begin
        Dir.cd path
        shell.state.dir_history << path
      rescue
        "Directory #{path} does not exist".colorize(:red)
      end
    end
  end
end
