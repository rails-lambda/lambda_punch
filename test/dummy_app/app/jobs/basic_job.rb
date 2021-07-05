class BasicJob < ApplicationJob
  def perform(object)
    TestHelpers::PerformBuffer.add "BasicJob with: #{object.inspect}"
  end
end
