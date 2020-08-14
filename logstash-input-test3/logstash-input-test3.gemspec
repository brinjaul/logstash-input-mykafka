Gem::Specification.new do |s|
  s.name          = 'logstash-input-test3'
  s.version       = '0.1.0'
  s.licenses        = ['Apache-2.0']
  s.summary       = 'my firset gem for logstash plugin'
  s.description   = 'Write a longer description or delete this line.'
  s.homepage      = 'https://rubygems.org/profiles/brinjaul'
  s.authors       = ['brinajul']
  s.email         = '463232683@qq.com'
  s.require_paths = ['lib']
  s.platform = 'java'
  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22'
  s.add_development_dependency 'logstash-devutils', '>= 0.0.16'
  s.requirements << "jar 'org.apache.kafka:kafka-clients', '2.3.0'"
  s.add_runtime_dependency 'jar-dependencies'
end
