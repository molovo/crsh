module Crsh
  class Prompt
    def initialize(@shell : Shell)
    end

    def left
      "> "
    end

    def right
      Git.info
    end

    def dir
      Dir.current
    end

    def print
      cols = (`tput cols` || 80).to_i32
      width = cols - dir.size - right.size

      pad = " "
      prompt = "#{dir.colorize(:blue)}#{pad * width}#{right}"

      puts
      puts prompt
      left.to_s
    end
  end
end
