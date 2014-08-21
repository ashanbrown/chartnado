require 'active_support/core_ext'

module Chartnado
  module Series
    # @api public
    # @example
    #   series_product(2.0, {0 => 1}) => {0 => 2.0}
    #   series_product({0 => 1}, 2.0) => {0 => 2.0}
    #
    # @return [Series/Multiple-Series]
    def series_product(val, series, precision: 2)
      if dimensions(val) > dimensions(series)
        return series_product(series, val)
      end

      return with_precision(precision, val.to_f * series.to_f) unless series.respond_to?(:length)
      return series unless series.length > 0

      if is_an_array_of_named_series?(series) || series.is_a?(Array) && series.first.is_a?(Array)
        series.map { |(name, data)| [name, series_product(val, data)] }
      elsif series.is_a?(Hash)
        series.to_a.reduce({}) do |hash, (key, value)|
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
          hash[key] = scalar * value
          hash
        end
      else
        series.map do |value|
          val * value
        end
      end
    end

    # @api public
    # @example
    #   series_ratio({0 => 1}, 2.0) => {0 => 0.5}
    #
    # @return [Series/Multiple-Series]
    def series_ratio(top_series, bottom_series, multiplier: 1.0, precision: 2)
      if bottom_series.is_a?(Numeric)
        return series_product(1.0 * multiplier / bottom_series, top_series, precision: precision)
      end
      if has_multiple_series?(top_series) && !has_multiple_series?(bottom_series)
        top_series_by_name = data_by_name(top_series)
        if is_an_array_of_named_series?(top_series)
          top_series_by_name.map do |name, top_values|
            [
              name,
              series_ratio(top_values, bottom_series, multiplier: multiplier, precision: precision)
            ]
          end
        else
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
        end
      elsif is_an_array_of_named_series?(bottom_series)
        top_series_by_name = data_by_name(top_series)
        bottom_series.map do |(name, data)|
          [
            name,
            series_ratio(top_series_by_name[name], data, multiplier: multiplier, precision: precision)
          ]
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

    # @api public
    # @example
    #   series_sum({0 => 1}, 2.0) => {0 => 3.0}
    #   series_sum({0 => 1}, {0 => 1}) => {0 => 2}
    #   series_sum({0 => 1}, 2.0, 3.0) => {0 => 6.0}
    #   series_sum(1, 2) => 3
    #   series_sum() => []
    #
    # @return [Series/Multiple-Series/Scalar]
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
      elsif is_an_array_of_named_series?(series.first)
        series.flatten(1).group_by(&:first).map do |name, values|
          data = values.map(&:second).reduce(Hash.new(scalar_sum)) do |hash, values|
            values.each do |key, value|
              hash[key] += value
            end
            hash
          end
          [
            name, data
          ]
        end
      elsif series.first.is_a?(Array)
        series.map { |s| s.reduce(:+) + scalar_sum }
      else
        scalar_sum
      end
    end

    # @api public
    # @example
    #   median([0,1]) => {0.5}
    #   median([0,1,1,2,2]) => {1}
    #
    # @return Value
    def median(array)
      sorted = array.sort
      len = sorted.length
      (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
    end

    private

    def data_by_name(series)
      if is_an_array_of_named_series?(series)
        series.reduce({}) do |hash, value|
          hash[value.first] = value.second
          hash
        end
      else
        series.reduce({}) do |hash, (key, value)|
          new_key = Array.wrap(key.first).first
          hash[new_key] = {key => value }
          hash
        end
      end
    end

    def series_names(series)
      series.map { |key| key.first }.uniq
    end

    def has_multiple_series?(series)
      is_an_array_of_named_series?(series) || series.is_a?(Hash) && series.first && series.first[0].is_a?(Array) && series.first[0].length > 1
    end

    def is_an_array_of_named_series?(series)
      series.is_a?(Array) && series.first.second.is_a?(Hash)
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
