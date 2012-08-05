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
        @rules = enumeration.map { |c| TestInterface::Constraint::Type.new(@exception, c) }
        @constrained_argument_count = enumeration.size
      end
      private :set_constraints

      def unconstrained?(enumeration)
        enumeration.nil? or enumeration == UNCONSTRAINED_TYPE
      end
      private :unconstrained?

      def constrain(args)
        constrain_argument_count(args.size)
        constrain_each(args)
      end

      # TODO This is the only Constraint that knows about its own exception types. Push back.
      def constrain_argument_count(actual)
        if @constrained_argument_count && @constrained_argument_count != actual
          message = "wrong number of arguments (#{actual} for #@constrained_argument_count)"
          raise TestInterface::ArgumentCountViolation.new message
        end
      end
      private :constrain_argument_count

      def constrain_each(args)
        if @rules
          args.each_with_index do |o, i|
            @rules[i].constrain(o)
          end
        end
      end
      private :constrain_each

    end

  end

end