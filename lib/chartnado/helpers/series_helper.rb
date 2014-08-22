module Chartnado::Helpers
  module Series
    extend ActiveSupport::Concern

    module ClassMethods
      def define_series(name, &block)
        define_method(name) do
          Chartnado.with_chartnado_dsl do
            self.instance_exec(&block)
          end
        end

        memoized_name = :"@_memoized_#{name}"
        define_method(:"#{name}_with_memoized") do |suffix: nil|
          current_value = instance_variable_get(memoized_name)
          if !current_value
            series = send(:"#{name}_without_memoized")
            instance_variable_set(memoized_name, series)
          else
            series = current_value
          end
          series = add_suffix_to_series_name(series, suffix) if suffix
          series
        end
        alias_method_chain name, :memoized
      end

      def define_multiple_series(series)
        series.each do |name, proc|
          define_series(name, &proc)
        end
      end
    end
  end
end
