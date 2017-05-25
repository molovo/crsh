module Crsh
  class Config
    alias Store = Hash(String, Value)
    alias Value = String | Int32 | Bool | Array(Value)

    @values : Store = {
      "autosuggestions"     => true.as(Value),
      "syntax_highlighting" => true.as(Value),
    }

    def initialize(@shell : Shell)
    end

    macro method_missing(call)
      {% method = call.name.id.stringify %}
      {% if call.name.id.last == "=" %}
        @values[{{ method }}] = {{ *call.args }}
      {% else %}
        if @values.has_key?({{ method }})
          @values[{{ method }}]
        end
      {% end %}
    end
  end
end
