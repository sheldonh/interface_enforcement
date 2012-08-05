module TestInterface

  module Constraint

    class Type

      def initialize(exception, type)
        @exception = exception
        @type = type
      end

      def constrain(o)
        raise @exception unless unconstrained? or o.is_a?(@type)
      end

      private

      def unconstrained?
        @type.nil? or @type == UNCONSTRAINED_TYPE
      end

    end

  end

end