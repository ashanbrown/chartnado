require 'chartnado/chart'

module Chartnado::ChartHelpers
  include Chartnado::Chart

  def area_chart(*)
    super
  end

  def area_chart_with_dsl(*args, ** options, &block)
    render_chart(*args, **options) do |chartkick_options, json_options|
      area_chart_without_dsl(**chartkick_options) do
        evaluate_chart_block(**json_options, &block)
      end
    end
  end

  alias_method_chain :area_chart, :dsl

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
      area_chart_without_dsl(**new_options) do
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

  def pie_chart(*args, ** options, &block)
    render_chart(*args, **options) do |chartkick_options, json_options|
      super(*chartkick_options) do
        evaluate_chart_block(**json_options, &block)
      end
    end
  end

  def column_chart(*args, ** options, &block)
    render_chart(*args, **options) do |chartkick_options, json_options|
      super(**chartkick_options) do
        evaluate_chart_block(**json_options, &block)
      end
    end
  end

  private

  def render_chart(*args, **options, &block)
    name = args[0] or raise "chart must have a name"
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

    haml_concat(render(layout: 'admin/charts/chart', locals: {title: name}) do
      block.call(chartkick_options, json_options)
    end)
  end

  def evaluate_chart_block(*args, &block)
    chart_json(Chartnado.with_chartnado_dsl(&block), *args)
  end
end
