class Chartnado::Renderer
  include Chartnado::Series

  attr_accessor :context, :data_block, :render_block

  def initialize(context, data_block, &render_block)
    @context = context
    @data_block = data_block
    @render_block = render_block
  end

  delegate :controller, to: :context

  def render(*args, **options)
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

    chart_json_proc = -> (*args) {
      chart_json(Chartnado.with_chartnado_dsl(&data_block), *args)
    }
    renderer = -> {
      context.instance_exec(chartkick_options, json_options, chart_json_proc, &render_block)
    }

    if options[:wrapper_proc]
      context.instance_exec(*args, renderer, **options, &options[:wrapper_proc])
    else
      renderer.call
    end
  end

  def chart_json(series, show_total: false, reverse_sort: false, percentage: false)
    series = series_product(100.0, series) if percentage
    if series.is_a?(Hash) and (key = series.keys.first) and key.is_a?(Array) and key.size == 2
      totals = Hash.new(0.0)
      new_series = series.group_by{|k, v| k[0] }.sort_by { |k| k.to_s }
      new_series = new_series.reverse if reverse_sort

      new_series = new_series.map do |name, data|
        {
          name: name,
          data: data.map do |k, v|
            totals[k[1]] += v if show_total
            [k[1], v]
          end
        }
      end

      if show_total
        [{name: 'Total',
          data: totals.map {|k,v| [k, 0] },
          tooltip: totals.map {|k,v| [k, v] }
         }] + new_series
      else
        new_series
      end
    elsif series.is_a?(Array) && series.first.is_a?(Array)
      totals = Hash.new(0.0)
      new_series = series.sort_by { |item| item.first.to_s }
      new_series = new_series.reverse if reverse_sort

      new_series = new_series.map do |name, data|
        {
          name: name,
          data: data.map do |k, v|
            totals[k] += v if show_total
            [k, v]
          end
        }
      end

      if show_total
        [{name: 'Total',
          data: totals.map {|k,v| [k, 0] },
          tooltip: totals.map {|k,v| [k, v] }
         }] + new_series
      else
        new_series
      end
    else
      series
    end
  end
end
