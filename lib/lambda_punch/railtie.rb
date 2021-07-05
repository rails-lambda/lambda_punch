require 'rails'
require 'rails/engine'
require 'active_job'
  
module LambdaPunch
  class Railtie < Rails::Railtie
    railtie_name :lambda_punch

    rake_tasks do
      load "lambda_punch/tasks/install.rake"
    end
  end
end
