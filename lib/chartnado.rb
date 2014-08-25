require 'chartnado/version'
require 'chartnado/series'
require 'chartnado/group_by'
require 'chartnado/evaluator'
require 'chartnado/helpers/chart_helper'
require 'chartnado/helpers/series_helper'
require 'chartnado/hash'
require 'chartkick/remote'
require 'chartnado/engine' if defined?(Rails)

module Chartnado
  extend ActiveSupport::Concern
  attr_accessor :chartnado_options

  included do
    include Chartkick::Remote

    helper Chartnado::Helpers::Chart
  end

  module ClassMethods
    def chartnado_wrapper(wrapper_symbol = nil, **options, &block)
      unless block
        helper_method wrapper_symbol
        block = -> (*args, **options) do
          render_block = args.pop
          send(wrapper_symbol, *args, **options, &render_block)
        end
      end

      action_filter_options = options.extract!(:only, :except)

      before_filter action_filter_options do
        self.chartnado_options ||= {}
        self.chartnado_options[:wrapper_proc] = block
      end
    end
  end
end
