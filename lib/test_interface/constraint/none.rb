module TestInterface

  module Constraint

    class None

      def initialize(exception)
        @exception = exception
      end

      def constrain(o)
        raise @exception unless nothing_received?(o)
      end

      private

      def nothing_received?(o)
        o.respond_to?(:empty?) and o.empty?
      end

    end

  end

end