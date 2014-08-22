require 'chartnado/chart'
require 'chartkick'

# These helpers can be included in your view using `helper Chartnado::Helpers::Chart`.
# They override the default chartkick chart rendering methods with ones that support chartnado DSL.
module Chartnado::Helpers
  module Chart
    include Chartkick::Helper
    include Chartnado::Chart

    def stacked_area_chart(*args, ** options, &block)
      render_chart(*args, **options) do |chartkick_options, json_options|
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
          evaluate_chart_block(json_options.reverse_merge(show_total: true, reverse_sort: true), &block)
        end
      end
    end

    def line_chart(*args, ** options, &block)
      render_chart(*args, **options) do |chartkick_options, json_options|
        new_options = chartkick_options.reverse_merge(
          library: {
            curveType: "none",
            pointSize: 2,
            focusTarget: 'category'
          })
        super(**new_options) do
          evaluate_chart_block(**json_options, &block)
        end
      end
    end

    %i{geo_chart pie_chart column_chart area_chart}.each do |chart_type|
      define_method(:"#{chart_type}_with_chartnado") do |*args,
        ** options, &block |
        render_chart(*args, ** options) do |chartkick_options, json_options|
          send(:"#{chart_type}_without_chartnado", ** chartkick_options) do
            evaluate_chart_block(** json_options, &block)
          end
        end
      end
      alias_method_chain chart_type, :chartnado
    end

    private

    def render_chart(*args, **options, &render_block)
      json_options = {}
      chartkick_options = options.dup

      if args.length > 1
        if args.last.is_a?(Hash)
          json_options = chartkick_options
          chartkick_options = args[1].dup
        end
        args.select { |arg| arg.is_a?(Symbol) }.each do |key|
          json_options[key] = true unless json_options.has_key?(key)
        end
      end

      if json_options[:percentage]
        chartkick_options.reverse_merge!(max: 100.0)
      end

      options = controller.chartnado_options if controller.respond_to?(:chartnado_options)
      options ||= {}

      helper = self

      renderer = -> { helper.instance_exec(chartkick_options, json_options, &render_block) }

      if options[:wrapper_proc]
        helper.instance_exec(*args, renderer, **options, &options[:wrapper_proc])
      else
        renderer.call
      end
    end

    def evaluate_chart_block(*args, &block)
      chart_json(Chartnado.with_chartnado_dsl(&block), *args)
    end
  end
end
