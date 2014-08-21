require 'chartnado/series'

module Chartnado::GroupBy
  include Chartnado::Series

  # @api public
  # @example
  #   group_by('tasks.user_id', Task.all) { count('DISTINCT project_id') }
  #
  # @return [Multiple-Series]
  def group_by(group_name, scope, label_block = nil, &eval_block)
    group_values = [group_name] + scope.group_values
    series = scope.except(:group).group(group_values).
      instance_eval(&eval_block)

    if label_block
      update_key_from_block = lambda do |(key, data)|
        if key.is_a?(Array)
          group_key = key.first
          sub_key = key[1..-1]
          sub_key = sub_key.first if sub_key.length == 1
          data = {sub_key => data}
        else
          group_key = key
        end
        (new_key, data) = label_block.call(group_key, data)
        if key.is_a?(Array)
          {[new_key, *Array.wrap(sub_key)] => data.values.first}
        else
          {new_key => data}
        end
      end

      if series.length > 0
        series_sum *series.map(&update_key_from_block)
      else
        {}
      end
    else
      series
    end
  end


  # @api public
  # @example
  #   mean([0,1]) => {0.5}
  #
  # @return Value
  def mean(array)
    array.reduce(:+) / array.length
  end

  # @api public
  # @return Value
  def harmonic_mean(array)
    array = array.reject(&:zero?)
    return nil unless array.present?
    array.size / (array.reduce(0) { |mean, value| mean + 1.0 / value })
  end

  # @api public
  # @return Value
  def geometric_mean(array)
    array.reduce(:*) ** (1.0 / array.length)
  rescue Math::DomainError
    nil
  end

  # @api public
  # @return Value
  def grouped_median(series)
    series.group_by(&:first).reduce({}) do |hash, (key, values)|
      hash[key] = median(values.map(&:second))
      hash
    end
  end

  # @api public
  # @return Value
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
end
