module InterfaceEnforcement

  module Constraint

    class Type

      def initialize(type)
        @type = type
      end

      def allows?(o)
        o.is_a?(@type)
      end

    end

  end

end