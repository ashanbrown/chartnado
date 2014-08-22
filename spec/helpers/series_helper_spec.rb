require 'spec_helper'
require 'rails_helper'

describe Chartnado::Helpers::Series, type: :helper do
  let(:test_class) {
    Class.new do
      include Chartnado::Helpers::Series
    end
  }

  describe ".define_series" do
    it "lets the user define a series using the chartnado dsl" do
      test_class.class_eval do
        define_series :my_series do
          {0 => 1} / 2
        end
      end
      expect(test_class.new.my_series).to eq({0 => 0.5})
    end
  end
  describe ".define_multiple_series" do
    it "lets the user define multiple series using the chartnado dsl" do
      test_class.class_eval do
        define_multiple_series(
          my_first_series: -> { {0 => 1} / 2 },
          my_second_series: -> { {1 => 1} / 2 }
        )
      end
      expect(test_class.new.my_first_series).to eq({0 => 0.5})
      expect(test_class.new.my_second_series).to eq({1 => 0.5})
    end
  end
end
