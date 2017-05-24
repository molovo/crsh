module Crsh
  class PathStore
    @dirs = [] of String

    def add(path : String)
      path = File.expand_path path
      if Dir.exists? path
        @dirs << path
      end
    end

    def rm(path : String)
      path = File.expand_path path
      if @dirs.includes? path
        @dirs.delete path
      end
    end
  end
end
