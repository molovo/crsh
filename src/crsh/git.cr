module Crsh
  class Git
    def self.info
      "#{self.branch}#{self.status}"
    end

    def self.branch
      branch = `git status --short --branch -uno --ignore-submodules=all | head -1 | awk '{print $2}' 2>/dev/null`.lines.first?

      if branch.nil?
        return nil
      else
        separator_index = branch.index("...")
        if separator_index.nil?
          return branch
        else
          return branch[0, separator_index]
        end
      end
    end

    def self.status
    end
  end
end
