module Chartnado::Chart
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
