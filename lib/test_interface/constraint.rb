require 'test_interface/constraint/enumeration'
require 'test_interface/constraint/none'
require 'test_interface/constraint/open'
require 'test_interface/constraint/rule'
require 'test_interface/constraint/type'

module TestInterface

  module Constraint

    UNCONSTRAINED_TYPE = :any

    def self.build(specification, *strategies)
      Builder.new(specification, *strategies).build
    end

    private

    class Builder

      def initialize(specification, *strategies)
        @specification = specification
        @strategies = strategies
      end

      def build
        @strategies.detect { |strategy| @constraint = try_build(strategy) }
        @constraint
      end

      private

      def try_build(strategy)
        send("build_#{strategy}")
      end

      def build_any
        Constraint::Open.new if @specification.nil? or @specification == UNCONSTRAINED_TYPE
      end

      def build_enum
        Constraint::Enumeration.new(@specification) if @specification.is_a?(Enumerable)
      end

      def build_enum_of_one
        Constraint::Enumeration.new([@specification]) if @specification.is_a?(Module)
      end

      def build_none
        Constraint::None.new if @specification == :none
      end

      def build_rule
        Constraint::Rule.new(@specification) if @specification.is_a?(Proc)
      end

      def build_type
        Constraint::Type.new(@specification) if @specification.is_a?(Module)
      end

    end

  end

end
