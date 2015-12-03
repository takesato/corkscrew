require 'corkscrew/version'

module Corkscrew
  class Git
    def initialize(hash)
      @hash = hash
    end

    def commit_list(parent)
      ancestry = `git rev-list --ancestry-path #{@hash}..#{parent}`.split("\n")
      first_parent = `git rev-list --first-parent #{@hash}..#{parent}`.split("\n")
      ancestry & first_parent
    end

    def pr_number(merge_commit)
      pull_request_number = `git log -1 --format=%B #{merge_commit}`.split("\n").first
      pull_request_number.match(/^.*#([0-9]*).*$/)[1]
    end

    def branchs
      `git branch -r`
        .split("\n")
        .reject { |branch| branch =~ /.*\/HEAD / }
        .map { |branch| branch.chomp }
    end

    def open
      merge_commit = branchs.map { |branch| commit_list(branch) }.flatten.uniq.last
      num = pr_number(merge_commit)
      url_base = `hub browse -u`.chomp
      `open #{url_base}/pull/#{num}`
    end
  end
end
