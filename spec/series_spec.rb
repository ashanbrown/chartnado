require 'spec_helper'

describe Chartnado::Series do
  before do
    class << self
      include Chartnado::Series
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
    describe "multiplying an hash of named series by a scalar" do
      it "returns the product of a scalar and each named_series" do
        expect(
          series_product(
            2,
            {[:series_a, 0] => 3,
             [:series_b, 1] => 4}
          )).to eq ({[:series_a, 0] => 6, [:series_b, 1] => 8})
      end
    end
    describe "multiplying an array of named series by a scalar" do
      it "returns the product of a scalar and each named_series" do
        expect(
          series_product(
            2,
            [[:series_a, {0 => 3}],
             [:series_b, {1 => 4}]]
          )).to eq [[:series_a, {0 => 6}], [:series_b, {1 => 8}]]
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
    describe "adding a scalar to an array of named series" do
      it "returns each item of the array with a scalar added" do
        expect(series_sum(2,[[:a, {0 => 3}]])).to eq ([[:a, {0 => 5}]])
      end
    end
    describe "adding a scalar to an hash of named series" do
      it "returns each item of the array with a scalar added" do
        expect(series_sum(2,{'a' => {0 => 3}})).to eq ([['a', {0 => 5}]])
      end
    end
    describe "adding a scalar to a hash with 2 dimensional keys" do
      it "returns each item of the array with a scalar added" do
        expect(series_sum({['a', 0] => 3}, 1)).to eq ({['a', 0] => 4})
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
    describe "adding nothing but a scalar sum" do
      it "returns the scalar sum" do
        expect(series_sum(scalar_sum: 2)).to eq 2
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
    describe "ratio of an array of named series to another array of named series" do
      it "returns the ratio" do
        expect(series_ratio([[:series_a, {0 => 1}]],
                            [[:series_a, {0 => 2}]])).to eq [[:series_a, {0 => 0.5}]]
      end
    end
    describe "ratio of a named series to a non-named series" do
      it "returns the ratio" do
        expect(series_ratio({[:series_a, 0] => 1, [:series_a, 1] => 3},
                            {0 => 2, 1 => 4})).to eq ({[:series_a, 0] => 0.5, [:series_a, 1] => 0.75})
      end
      describe "when the keys are time values" do
        let(:t1) { Time.parse('2014-09-15 07:00:00 UTC') }
        let(:t2) { Time.parse('2014-09-22 07:00:00 UTC') }
        it "still returns the ratio" do
          expect(series_ratio({[:series_a, t1] => 1, [:series_a, t2] => 3},
                              {t1 => 2, t2 => 4})).to eq ({[:series_a, t1] => 0.5, [:series_a, t2] => 0.75})
        end
      end
    end
    describe "ratio of an array of named series to a non-named series" do
      it "returns the ratio" do
        expect(series_ratio([[:series_a, {0 => 1}]],
                            {0 => 2})).to eq [[:series_a, {0 => 0.5}]]
      end
    end
    describe "ratio of a hash of named series to a non-named series" do
      it "returns the ratio" do
        expect(series_ratio({:series_a => {0 => 1}},
                            {0 => 2})).to eq [[:series_a, {0 => 0.5}]]
      end
    end

    describe "ratio of a series to a scalar" do
      it "returns the ratio" do
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
end
