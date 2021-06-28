namespace :lambda_punch do

  desc "Install the LambdaPunch Lambda Extension."
  task :install do
    require 'fileutils'
    FileUtils.mkdir_p '/opt/extensions'
    extension = File.expand_path "#{__dir__}/../extensions/lambdapunch"
    FileUtils.cp extension, '/opt/extensions/'
  end

end
