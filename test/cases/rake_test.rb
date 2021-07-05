require 'test_helper'
load 'lambda_punch/tasks/install.rake'

class RakeTest < LambdaPunchSpec

  before do
    FileUtils.rm_rf '/opt/extensions'
  end

  it 'installs extension' do
    refute File.exist?('/opt/extensions/lambdapunch')
    Rake::Task['lambda_punch:install'].execute
    assert File.exist?('/opt/extensions/lambdapunch')
  end

end
