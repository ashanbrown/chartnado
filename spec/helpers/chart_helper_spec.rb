require 'spec_helper'
require 'rails_helper'

describe Chartnado::Helpers::Chart, type: :helper do
  def works?(&block)
    expect {
      block.call
    }.not_to raise_exception
  end

  describe "#area_chart" do
    it "supports the dsl" do
      works? { helper.area_chart { {1 => 2} / 2.0 } }
    end
  end

  describe "#stacked_area_chart" do
    it "supports the dsl" do
      works? { helper.stacked_area_chart { {1 => 2} / 2.0 } }
    end
    describe "percentage option" do
    end
  end

  describe "#pie_chart" do
    it "supports the dsl" do
      works? { helper.pie_chart { {1 => 2} / 2.0 } }
    end
  end

  describe "#geo_chart" do
    it "supports the dsl" do
      works? { helper.geo_chart { {1 => 2} / 2.0 } }
    end
  end

  describe "#line_chart" do
    it "supports the dsl" do
      works? { helper.line_chart { {1 => 2} / 2.0 } }
    end
    xit "includes total"
    describe "percentage option" do
    end
  end
end
