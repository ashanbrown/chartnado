module Chartnado
  class Evaluator < SimpleDelegator
    module Operators
      def self.included(base)
        %i{+ * - /}.each do |method|
          define_method method do |*args, &block|
            if Thread.current[:in_chartnado_block]
              OperatorEvaluator.new(self).send(method, *args)
            elsif defined?(super)
              super(*args, &block)
            else
              raise NoMethodError, "#{method} is not defined"
            end
          end
        end

        def coerce(other)
          return super unless Thread.current[:in_chartnado_block]
          if other.is_a?(Numeric)
            [self, other]
          else
            super
          end
        end
      end
    end

    class OperatorEvaluator
      include Series
      extend Forwardable

      def initialize(object)
        @object = object
      end

      def *(value)
        without_operators do
          series_product(@object, value)
        end
      end

      def +(value)
        without_operators do
          series_sum(value, @object)
        end
      end

      def -(value)
        self + -1.0 * value
      end

      def /(value)
        without_operators do
          series_ratio(@object, value)
        end
      end

      def_delegator Chartnado::Evaluator, :without_operators
    end

    def self.without_operators
      in_chartnado_block = Thread.current[:in_chartnado_block]
      Thread.current[:in_chartnado_block] = nil
      yield
    ensure
      Thread.current[:in_chartnado_block] = in_chartnado_block
    end

    def self.with_operators(&block)
      original_value = Thread.current[:in_chartnado_block]
      binding = eval 'self', block.binding
      Thread.current[:in_chartnado_block] = true
      Evaluator.new(binding).instance_eval(&block)
    ensure
      Thread.current[:in_chartnado_block] = original_value
    end
  end

  def self.with_chartnado_dsl(&block)
    Evaluator.with_operators(&block)
  end
end
