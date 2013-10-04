require "bundler/setup"

gemspec = eval(File.read("dubai.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["dubai.gemspec"] do
  system "gem build dubai.gemspec"
end
