require 'active_support/core_ext'
require 'chartnado/series/wrap'

module Chartnado
  module Series
    # @api public
    # @example
    #   series_product(2.0, {0 => 1}) => {0 => 2.0}
    #   series_product({0 => 1}, 2.0) => {0 => 2.0}
    #
    # @return [Series/Multiple-Series]
    def series_product(val, series, precision: 2)
      Wrap[series].times(val, precision: precision)
    end

    # @api public
    # @example
    #   series_ratio({0 => 1}, 2.0) => {0 => 0.5}
    #
    # @return [Series/Multiple-Series]
    def series_ratio(top_series, bottom_series, multiplier: 1.0, precision: 2)
      Wrap[top_series].
        over(bottom_series, multiplier: multiplier, precision: precision)
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
      Wrap[series.shift].add(*series, scalar_sum: scalar_sum)
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
  end
end
