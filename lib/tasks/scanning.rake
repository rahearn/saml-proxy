desc "Run brakeman with potential non-0 return code"
task :brakeman do
  # -z flag makes it return non-0 if there are any warnings
  # -q quiets output
  unless system("bin/brakeman -z -q") # system is true if return is 0, false otherwise
    abort("Brakeman detected one or more code problems, please run it manually and inspect the output.")
  end
end

namespace :bundler do
  require "bundler/audit/cli"

  desc "Updates the ruby-advisory-db and runs audit"
  task :audit do
    %w[update check].each do |command|
      Bundler::Audit::CLI.start [command]
    end
  end
rescue LoadError
  # no-op, probably in a production environment
end

task default: ["standard", "brakeman", "bundler:audit"]
