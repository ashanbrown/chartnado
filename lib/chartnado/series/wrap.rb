module Chartnado
  module Series
    class Wrap < SimpleDelegator
      def self.[](series)
        series.class == self ? series : new(series)
      end

      def *(val)
        times(val, precision: nil)
      end

      def times(factor, precision: 2)
        factor = wrap(factor)

        return factor.times(self, precision: precision) if factor.dimensions > dimensions
        return with_precision(precision, factor.to_f * to_f) unless dimensions > 1
        return self unless length > 0

        if has_separate_named_series? || array? && first.is_a?(Array)
          result = map { |(name, data)| [name, wrap(data) * factor] }
        elsif hash?
          result = to_a.reduce({}) do |hash, (key, value)|
            if factor.hash?
              if key.is_a?(Array)
                scalar = factor[key.second]
              else
                scalar = factor[key]
              end
            else
              scalar = factor
            end
            scalar ||= 0
            hash[key] = scalar * value
            hash
          end
        else
          result = map do |value|
            factor * value
          end
        end

        wrap(result)
      end

      def add(*series, scalar_sum: 0.0)
        (series, scalars) = [__getobj__, *series].partition { |s| s.respond_to?(:map) }
        scalar_sum += scalars.reduce(:+) || 0.0
        return wrap(scalar_sum) unless series.present?

        if wrap(series.first).has_separate_named_series?
          result = series.map(&:to_a).flatten(1).group_by(&:first).map do |name, values|
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
        elsif series.first.is_a?(Hash)
          keys = series.flat_map(&:keys).uniq
          result = keys.reduce({}) do |hash, key|
            hash[key] = (series.map { |s| s[key] }.compact.reduce(:+) || 0) + scalar_sum
            hash
          end
        elsif series.first.is_a?(Array)
          result = series.map { |s| s.reduce(:+) + scalar_sum }
        else
          result = scalar_sum
        end

        wrap(result)
      end

      def over(bottom, multiplier: 1.0, precision: 2)
        bottom = wrap(bottom)
        return times(1.0 * multiplier / bottom, precision: precision) if bottom.dimensions == 1

        if dimensions > bottom.dimensions
          top_series_by_name = data_by_name
          if has_separate_named_series?
            data_by_name.map do |name, top_values|
              [
                name,
                wrap(top_values).
                  over(bottom, multiplier: multiplier, precision: precision)
              ]
            end
          else
            bottom.reduce({}) do |hash, (key, value)|
              top_series_by_name.keys.each do |name|
                top_key = [name, *Array.wrap(key)]
                top_value = top_series_by_name[name][top_key]
                if top_value
                  hash[top_key] = wrap(top_value).
                    over(value, multiplier: multiplier, precision: precision)
                end
              end
              hash
            end
          end
        elsif array_of_named_series?
          top_series_by_name = data_by_name
          bottom.map do |(name, data)|
            [
              name,
              wrap(top_series_by_name[name]).
                over(data, multiplier: multiplier, precision: precision)
            ]
          end
        elsif bottom.respond_to?(:reduce)
          bottom.reduce({}) do |hash, (key, value)|
            hash[key] = wrap(self[key] || 0).
              over(value, multiplier: multiplier, precision: precision)
            hash
          end
        else
          with_precision(precision, to_f * multiplier.to_f / bottom.to_f)
        end
      end

      def has_multiple_series?
        array_of_named_series? || is_a?(Hash) && begin
          first_series = series.first
          first_series[0].is_a?(Array) && first_series[0].length > 1 || first_series[1].respond_to?(:length)
        end
      end

      def hash?
        __getobj__.is_a?(Hash)
      end

      def array?
        __getobj__.is_a?(Array)
      end

      def array_of_named_series?
        array? && first.second.is_a?(Hash)
      end

      def hash_of_named_series?
        hash? && values.first && values.first.is_a?(Hash)
      end

      def dimensions
        return 1 unless respond_to?(:length)
        if hash?
          if keys.first && keys.first.is_a?(Array) || hash_of_named_series?
            3
          else
            2
          end
        else
          if first && first.is_a?(Array)
            3
          else
            2
          end
        end
      end

      def has_separate_named_series?
        hash_of_named_series? || array_of_named_series?
      end

      private

      def data_by_name
        return self if hash_of_named_series?
        result = if array_of_named_series?
          reduce({}) do |hash, (name, values)|
            hash[name] = values
            hash
          end
        else
          hash = Hash.new { |hash, key| hash[key] = {} }
          x = reduce(hash) do |hash, (key, value)|
            p key.first
            new_key = Array.wrap(key.first).first
            hash[new_key][key] = value
            hash
          end
          p x
          x
        end
        wrap(result)
      end

      def with_precision(precision, value)
        value = value.round(precision) if precision
        value
      end

      def wrap(val)
        self.class[val]
      end
    end
  end
end
