require 'spec_helper'
require 'rails_helper'

describe "Controller Methods", type: :controller do
  render_views

  routes do
    ActionDispatch::Routing::RouteSet.new.tap do |routes|
      routes.draw { get "show" => "anonymous#show" }
    end
  end

  controller do
    include Chartnado

    chartkick_remote remote: false

    define_method :_routes do
      ActionDispatch::Routing::RouteSet.new.tap do |routes|
        routes.draw { get "show" => "anonymous#show" }
      end
    end

    def show
    end
  end

  describe ".chartnado_wrapper" do
    describe "when the wrapper is referenced by symbol" do
      before do
        controller.singleton_class.class_eval do
          chartnado_wrapper :wrap_chart

          def show
            render inline: "<% area_chart { {0 => 1} / 2.0 } %>"
          end
        end
      end

      it "calls the wrapper in the context of the helpers" do
        routes.draw { get "show" => "anonymous#show" }
        expect(controller).to receive(:wrap_chart)
        get :show
      end
    end

    describe "when the wrapper is desribed by a block" do
      before do
        controller.singleton_class.class_eval do
          chartnado_wrapper do |*args, **options, &block|
            throw :wrapper_was_called
          end

          def show
            render inline: "<% area_chart { {0 => 1} / 2.0 } %>"
          end
        end
      end

      it "calls the wrapper in the context of the helpers" do
        routes.draw { get "show" => "anonymous#show" }
        expect {
          get :show
        }.to throw_symbol :wrapper_was_called
      end
    end
  end
end
