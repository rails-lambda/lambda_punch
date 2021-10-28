require 'test_helper'

class NotifierTest < LambdaPunchSpec

  it 'has an accessor for the temp file' do
    expect(LambdaPunch.tmp_file).must_equal '/tmp/lambdapunch-handled'
  end

end
