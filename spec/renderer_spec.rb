require 'spec_helper'

describe Chartnado::Renderer do
  describe "#chart_json" do
    def chart_json(*series)
      Chartnado::Renderer.new(nil, nil).chart_json(*series)
    end

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
