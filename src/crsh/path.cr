require "./path_store"

module Crsh
  class Path < PathStore
    @dirs = [
      "/bin",
      "/usr/bin",
      "/usr/local/bin",
    ]

    def has?(cmd : String?)
      false if cmd.nil?
      @dirs.each do |dir|
        return true if File.exists? "#{dir}/#{cmd}"
      end
    end
  end
end
