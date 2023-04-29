require_relative "lib/lambda_punch/version"

Gem::Specification.new do |spec|
  spec.name          = "lambda_punch"
  spec.version       = LambdaPunch::VERSION
  spec.authors       = ["Ken Collins"]
  spec.email         = ["ken@metaskills.net"]
  spec.summary       = "LambdaPunch: Async Processing using Lambda Extensions"
  spec.description   = "LambdaPunch: Async Processing using Lambda Extensions"
  spec.homepage      = "https://github.com/rails-lambda/lambda_punch"
  spec.license       = "MIT"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rails-lambda/lambda_punch"
  spec.metadata["changelog_uri"] = "https://github.com/rails-lambda/lambda_punch/blob/main/CHANGELOG.md"
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features|images)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "rake"
  spec.add_dependency "rb-inotify"
  spec.add_dependency "timeout"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rails"
end
