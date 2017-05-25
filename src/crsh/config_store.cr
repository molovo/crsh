module Crsh
  alias Value = String | Int32 | Bool | ConfigStore | Array(Value)

  class ConfigStore < Hash(String, Value)
  end
end
