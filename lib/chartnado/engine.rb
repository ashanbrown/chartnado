module Chartnado
  class Engine < ::Rails::Engine

    initializer "precompile", :group => :all do |app|
      # use a proc instead of a string
      app.config.assets.precompile << Proc.new{|path| path == "chartkick-chartnado.js" }
    end

  end
end
