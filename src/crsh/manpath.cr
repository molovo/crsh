require "./path_store"

module Crsh
  class Manpath < PathStore
    @dirs = [
      "/usr/share/man/man1",
      "/usr/local/share/man/man1",
    ]

    def has?(cmd : String?)
      false if cmd.nil?
      @dirs.each do |dir|
        return true if File.exists? "#{dir}/#{cmd}.1"
      end
    end
  end
end
