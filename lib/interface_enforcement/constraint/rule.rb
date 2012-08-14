module InterfaceEnforcement

  module Constraint

    class Rule

      def initialize(callable)
        @callable = callable
      end

      def allows?(o)
        @callable.call(o)
      end

    end

  end

end