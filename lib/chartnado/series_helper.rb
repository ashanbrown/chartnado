require 'active_support/core_ext'

module Chartnado
  module SeriesHelper
    def series_product(val, series, precision: 2)
      if dimensions(val) > dimensions(series)
        return series_product(series, val)
      end

      return with_precision(precision, val.to_f * series.to_f) unless series.respond_to?(:length)
      return series unless series.length > 0

      if series.is_a?(Array) && series.first.is_a?(Array)
        series.map { |(name, data)| [name, series_product(val, data)] }
      elsif series.is_a?(Hash)
        series.to_a.map do |(key, value)|
          if val.is_a?(Hash)
            if key.is_a?(Array)
              scalar = val[key.second]
            else
              scalar = val[key]
            end
          else
            scalar = val
          end
          scalar ||= 0
          [key, scalar * value]
        end.to_h
      else
        series.map do |value|
          val * value
        end
      end
    end

    def series_ratio(top_series, bottom_series, multiplier: 1.0, precision: 2)
      if bottom_series.is_a?(Numeric)
        return series_product(1.0 * multiplier / bottom_series, top_series, precision: precision)
      end
      if has_multiple_series?(top_series) && !has_multiple_series?(bottom_series)
        top_series_by_name = data_by_name(top_series)
        bottom_series.reduce({}) do |hash, (key, value)|
          top_series_by_name.keys.each do |name|
            top_key = [name, *key]
            top_value = top_series_by_name[name][top_key]
            if top_value
              hash[top_key] = series_ratio(top_value, value, multiplier: multiplier, precision: precision)
            end
          end
          hash
        end
      elsif bottom_series.respond_to?(:reduce)
        bottom_series.reduce({}) do |hash, (key, value)|
          hash[key] = series_ratio(top_series[key] || 0, value, multiplier: multiplier, precision: precision)
          hash
        end
      else
        with_precision(precision, top_series.to_f * multiplier.to_f / bottom_series.to_f)
      end
    end

    def series_sum(*series, scalar_sum: 0.0)
      return [] unless series.length > 0

      (series, scalars) = series.partition { |s| s.respond_to?(:map) }
      scalar_sum += scalars.reduce(:+) || 0.0

      if series.first.is_a?(Hash)
        keys = series.map(&:keys).flatten(1).uniq
        keys.reduce({}) do |hash, key|
          hash[key] = (series.map { |s| s[key] }.compact.reduce(:+) || 0) + scalar_sum
          hash
        end
      elsif series.first.is_a?(Array)
        series.map { |s| s.reduce(:+) + scalar_sum }
      else
        scalar_sum
      end
    end

    def group_by(group_name, scope, eval_block, &block)
      group_values = [group_name] + scope.group_values
      series = scope.except(:group).group(group_values).
        instance_eval(&eval_block)

      if block
        update_key_from_block = lambda do |(key, data)|
          if key.is_a?(Array)
            group_key = key.first
            sub_key = key[1..-1]
            sub_key = sub_key.first if sub_key.length == 1
            data = {sub_key => data}
          else
            group_key = key
          end
          (new_key, data) = block.call(group_key, data)
          if key.is_a?(Array)
            {[new_key, *Array.wrap(sub_key)] => data.values.first}
          else
            {new_key => data}
          end
        end

        series_sum *series.map(&update_key_from_block)
      else
        series
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

    def median(array)
      sorted = array.sort
      len = sorted.length
      (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end

    def mean(array)
      array.reduce(:+) / array.length
    end

    def harmonic_mean(array)
      array = array.reject(&:zero?)
      return nil unless array.present?
      array.size / (array.reduce(0) { |mean, value| mean + 1.0 / value })
    end

    def geometric_mean(array)
      array.reduce(:*) ** (1.0 / array.length)
    rescue Math::DomainError
      nil
    end

    def grouped_median(series)
      series.group_by(&:first).map do |key, values|
        [key, median(values.map(&:second))]
      end.to_h
    end

    def grouped_mean_and_median(series)
      series.group_by(&:first).reduce({}) do |hash, (key, values)|
        values = values.map(&:second).compact
        next hash unless values.present?
        hash[['median', key]] = median(values)
        hash[['mean', key]] = mean(values)
        hash[['geometric', key]] = geometric_mean(values)
        hash[['harmonic', key]] = harmonic_mean(values)
        hash
      end
    end

    private

    def data_by_name(series)
      series.index_by { |key| Array.wrap(key.first).first }.map { |name, (k,v)| [name, k => v] }.to_h
    end

    def series_names(series)
      series.map { |key| key.first }.uniq
    end

    def has_multiple_series?(series)
      series.is_a?(Hash) && series.first && series.first[0].is_a?(Array) && series.first[0].length > 1
    end

    def dimensions(series)
      return 1 unless series.respond_to?(:length)
      if series.first && series.first.is_a?(Array)
        3
      else
        2
      end
    end

    def with_precision(precision, value)
      value = value.round(precision) if precision
      value
    end
  end
end
