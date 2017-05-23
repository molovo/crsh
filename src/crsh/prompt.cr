module Crsh
  class Prompt
    def left
      Crsh.output.bold.green "> "
    end

    def right
      Git.info
    end

    def print
      cols = (`tput cols`.lines.first? || 80).to_i32
      width = cols - right.size

      pad = " "
      prompt = "#{pad * width}#{right}"
      "#{prompt}\r#{left}"
    end
  end
end
