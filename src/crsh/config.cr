module Crsh
  class Config
    @values = {
      "autosuggestions"     => false,
      "syntax_highlighting" => true,
    }

    def initialize(@shell : Shell)
    end

    macro method_missing(call)
      if @values.has_key?({{ call.name.id.stringify }})
        @values[{{ call.name.id.stringify }}]
      end
    end
  end
end
