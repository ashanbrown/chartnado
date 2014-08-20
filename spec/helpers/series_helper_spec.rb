require 'spec_helper'

describe Chartnado::SeriesHelper do
  before do
    class << self
      include Chartnado::SeriesHelper
    end
  end

  describe "#series_product" do
    describe "multiplying a hash by a scalar" do
      it "returns the product of a scalar and a hash" do
        expect(series_product(2, {0 => 3})).to eq ({0 => 6})
      end
    end
    describe "multiplying an array by a scalar" do
      it "returns the product of a scalar and a hash" do
        expect(series_product(2, [3, 7])).to eq [6, 14]
      end
    end
    describe "multiplying an scalar by a scalar" do
      it "returns the product of a scalar and a hash" do
        expect(series_product(2, 3)).to eq 6
      end
    end
    describe "multiplying an array of named series by a scalar" do
      it "returns the product of a scalar and each named_series" do
        expect(
          series_product(
            2,
            {[:series_a, 0] => 3,
             [:series_b, 1] => 4}
          )).to eq ({[:series_a, 0] => 6, [:series_b, 1] => 8})
      end
    end
  end

  describe "#series_sum" do
    describe "adding two scalars" do
      it "returns the sum of the scalars" do
        expect(series_sum(2,3)).to eq 5
      end
    end
    describe "adding a scalar to an array" do
      it "returns each item of the array with a scalar added" do
        expect(series_sum(2,[3])).to eq [5]
      end
    end
    describe "adding a scalar to a hash" do
      it "returns each item of the array with a scalar added" do
        expect(series_sum(2,{0 => 3})).to eq ({0 => 5})
      end
    end
    describe "adding two hashes" do
      it "returns each item of the array with a scalar added" do
        expect(series_sum({0 => 1},{0 => 2})).to eq ({0 => 3})
      end
    end
    describe "adding two hashes and a scalar" do
      it "returns each item of the array with a scalar added" do
        expect(series_sum({0 => 1},{0 => 2}, 5)).to eq ({0 => 8})
      end
    end
  end

  describe "#series_ratio" do
    describe "ratio of two scalars" do
      it "returns the ratio" do
        expect(series_ratio(1, 2)).to eq 0.5
      end
    end
    describe "ratio of two hashes" do
      it "returns the ratio" do
        expect(series_ratio({0 => 1}, {0 => 2})).to eq ({0 => 0.5})
      end
    end
    describe "ratio of a named series to another named series" do
      it "returns the ratio" do
        expect(series_ratio({[:series_a, 0] => 1},
                            {[:series_a, 0] => 2})).to eq ({[:series_a, 0] => 0.5})
      end
    end
    describe "ratio of a named series to a non-named series" do
      it "returns the ratio" do
        expect(series_ratio({[:series_a, 0] => 1},
                            {0 => 2})).to eq ({[:series_a, 0] => 0.5})
      end
    end
    describe "ratio of a series to a scalar" do
      xit "returns the ratio" do
        expect(series_ratio({0 => 1}, 2)).to eq ({0 => 0.5})
      end
    end

    describe "including a multiplier" do
      describe "for ratio of two scalars" do
        it "returns the ratio times the multiplier" do
          expect(series_ratio(1, 2, multiplier: 100)).to eq 50
        end
      end
    end

    describe "specifying the precision" do
      describe "for ratio of two scalars" do
        it "returns the ratio rounded to the specified precision" do
          expect(series_ratio(1, 3, precision: 1)).to eq 0.3
        end
      end
    end
  end

  describe "#chart_json" do
    describe "for data formatted as a hash" do
      it "can generate chartkick compatible series" do
        expect(chart_json({[:a, 1] => 10, [:b, 1] => 20})).
          to eq [{name: :a, data: [[1, 10]]}, {name: :b, data: [[1,20]]}]
      end
      it "can add totals" do
        expect(chart_json({[:a, 1] => 10, [:b, 1] => 20}, show_total: true)).
          to eq [{name: 'Total', data: [[1, 0]], tooltip: [[1, 30.0]]},
                 {name: :a, data: [[1, 10]]},
                 {name: :b, data: [[1, 20]]}]
      end
    end
    describe "for data formatted as an array" do
      it "can generate chartkick compatible series" do
        expect(chart_json([[:a, {1 => 10}], [:b, {1 => 20}]])).
          to eq [{name: :a, data: [[1, 10]]}, {name: :b, data: [[1,20]]}]
      end
      it "can add totals" do
        expect(chart_json([[:a, {1 => 10}], [:b, {1 => 20}]], show_total: true)).
          to eq [{name: 'Total', data: [[1, 0]], tooltip: [[1, 30.0]]},
                 {name: :a, data: [[1, 10]]},
                 {name: :b, data: [[1, 20]]}]
      end
    end
  end
end
