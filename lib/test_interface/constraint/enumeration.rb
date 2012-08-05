module TestInterface

  module Constraint

    class Enumeration

      # TODO Push unconstrained? decision back to caller.
      def initialize(exception, enumeration)
        @exception = exception
        set_constraints(enumeration) unless unconstrained?(enumeration)
      end

      def set_constraints(enumeration)
        enumeration = [ enumeration ] unless enumeration.is_a?(Enumerable)
        @rules = enumeration.map { |c| Constraint::Type.new(@exception, c) }
        @constrained_enum_size = enumeration.size
      end
      private :set_constraints

      def unconstrained?(enumeration)
        enumeration.nil? or enumeration == UNCONSTRAINED_TYPE
      end
      private :unconstrained?

      def constrain(enum)
        constrain_enum_size(enum.size)
        constrain_each(enum)
      end

      # TODO Use of "arguments" in message is smelly.
      def constrain_enum_size(actual)
        if @constrained_enum_size && @constrained_enum_size != actual
          message = "wrong number of arguments (#{actual} for #@constrained_enum_size)"
          raise @exception, message
        end
      end
      private :constrain_enum_size

      def constrain_each(enum)
        if @rules
          enum.each_with_index do |o, i|
            @rules[i].constrain(o)
          end
        end
      end
      private :constrain_each

    end

  end

end