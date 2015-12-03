require 'corkscrew/version'

module Corkscrew
  class Git
    def initialize(hash)
      @hash = hash
    end

    def open
      if url_base.nil?
        $stderr.puts "It's not a github repository."
        exit 1
      end
      merge_commits = branchs.map { |branch| candidate(branch) }.flatten.uniq
      number = merge_commits.map { |merge_commit| pr_number(merge_commit) }.compact.min

      if number.nil?
        $stderr.puts "PR number.was not found."
        exit 1
      end
      `open #{url_base}/pull/#{number}`
    end

    private
    def url_base
      `hub browse -u`.chomp
      remote = `git  remote -v`.split("\n").first
      user_repo = remote.match(/git@github.com\/(.*)\.git/)[1]
      "https://github.com/#{user_repo}" if user_repo
    end

    def candidate(parent)
      ancestry = `git rev-list --ancestry-path #{@hash}..#{parent}`.split("\n")
      first_parent = `git rev-list --first-parent #{@hash}..#{parent}`.split("\n")
      ancestry & first_parent
    end

    def pr_number(merge_commit)
      commit_message = `git log -1 --format=%B #{merge_commit}`.split("\n").first
      if commit_message = ~ /^.*#([0-9]*).*$/
        commit_message.match(/^.*#([0-9]*).*$/)[1]
      end
    end

    def branchs
      `git branch -r`
        .split("\n")
        .reject { |branch| branch =~ /.*\/HEAD / }
        .map { |branch| branch.chomp }
    end
  end
end
