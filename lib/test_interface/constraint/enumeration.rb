module TestInterface

  module Constraint

    class Enumeration

      # TODO Establish a factory layer and push this decision up as a .build strategy
      def initialize(exception, enumeration)
        @exception = exception
        @rules = enumeration.map do |c|
          if c.is_a?(Module)
            Constraint::Type.new(@exception, c)
          else
            Constraint::Open.new
          end
        end
      end

      def constrain(enum)
        raise @exception unless @rules.size == enum.size
        enum.each_with_index do |o, i|
          @rules[i].constrain(o)
        end
      end

    end

  end

end