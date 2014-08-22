require 'chartnado/renderer'
require 'chartkick'
require 'chartkick/remote/helper'

# These helpers can be included in your view using `helper Chartnado::Helpers::Chart`.
# They override the default chartkick chart rendering methods with ones that support chartnado DSL.
module Chartnado::Helpers
  module Chart
    include Chartkick::Helper
    include Chartkick::Remote::Helper

    def stacked_area_chart(*args, **options, &block)
      Chartnado::Renderer.new(self, block) do |chartkick_options, json_options, data_block|
        new_options = chartkick_options.reverse_merge(
          stacked: true,
          library: {
            focusTarget: 'category',
            series: {
              0 => {
                lineWidth: 0,
                pointSize: 0,
                visibleInLegend: false
              }
            }
          }
        )
        area_chart_without_chartnado(**new_options) do
          data_block.call(json_options.reverse_merge(show_total: true, reverse_sort: true))
        end
      end.render(*args, **options)
    end

    def line_chart_with_chartnado(*args, **options, &block)
      Chartnado::Renderer.new(self, block) do |chartkick_options, json_options, data_block|
        new_options = chartkick_options.reverse_merge(
          library: {
            curveType: "none",
            pointSize: 2,
            focusTarget: 'category'
          })
        line_chart_without_chartnado(**new_options) do
          data_block.call(**json_options)
        end
      end.render(*args, **options)
    end

    alias_method_chain :line_chart, :chartnado

    %i{geo_chart pie_chart column_chart bar_chart area_chart}.each do |chart_type|
      define_method(:"#{chart_type}_with_chartnado") do |*args, **options, &block|
        Chartnado::Renderer.new(self, block) do |chartkick_options, json_options, data_block|
          send(:"#{chart_type}_without_chartnado", **chartkick_options) do
            data_block.call(**json_options)
          end
        end.render(*args, **options)
      end
      alias_method_chain chart_type, :chartnado
    end
  end
end
