module Crsh
  class Input
    def self.get_command(ctx)
      line = ctx.editor.line
      cursor = ctx.editor.cursor.clamp(0, line.size - 1)
      pipe = line.rindex('|', cursor)
      line = line[(pipe + 1)..-1] if pipe

      line.split.first?
    end
  end
end
