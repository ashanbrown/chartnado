require 'spec_helper'

describe Chartnado::Renderer do
  describe "#chart_json" do
    def chart_json(*series, **options)
      Chartnado::Renderer.new(nil, nil).chart_json(*series, **options)
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
      it "can add multiply by 100 to create a percentage" do
        expect(chart_json({[:a, 1] => 0.1, [:b, 1] => 0.2}, percentage: true, show_total: true)).
          to eq [{name: 'Total', data: [[1, 0]], tooltip: [[1, 30.0]]},
                 {name: :a, data: [[1, 10.0]]},
                 {name: :b, data: [[1, 20.0]]}]
      end
      describe "with multiple scalar series" do
        it "can handle scalars" do
          expect(chart_json({:a => 10, :b => 20})).
            to eq([[:a, 10], [:b, 20]])
        end
        it "can add totals" do
          expect(chart_json({:a => 10, :b => 20}, show_total: true)).
            to eq([[:a, 10], [:b, 20], ['Total', 30]])
        end
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
    describe "for data that is just a scalar" do
      it "shows the scalar as the total" do
        expect(chart_json(10)).
          to eq [['Total', 10]]
      end
    end
  end
end
