require 'chartnado/version'
require 'chartnado/series'
require 'chartnado/group_by'
require 'chartnado/chart'
require 'chartnado/evaluator'
require 'chartnado/helpers/chart_helper'
require 'chartnado/helpers/series_helper'
require 'chartnado/hash'

module Chartnado
  extend ActiveSupport::Concern
  attr_accessor :chartnado_options

  module ClassMethods
    def chartnado_wrapper(symbol = nil, **options, &block)
      block ||= -> (*args) do
        send(symbol, *args)
      end

      action_filter_options = options.extract!(:only, :except)

      before_filter action_filter_options do
        self.chartnado_options ||= {}
        self.chartnado_options[:wrapper_proc] = block
      end
    end
  end
end
