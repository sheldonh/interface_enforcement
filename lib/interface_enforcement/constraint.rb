require 'interface_enforcement/constraint/enumeration'
require 'interface_enforcement/constraint/none'
require 'interface_enforcement/constraint/open'
require 'interface_enforcement/constraint/rule'
require 'interface_enforcement/constraint/type'

module InterfaceEnforcement

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
        @constraint or raise ArgumentError, "all strategies gave up on #{@specification.inspect}"
      end

      private

      def try_build(strategy)
        send("build_#{strategy}")
      rescue NoMethodError
        raise ArgumentError, "unknown constraint builder strategy #{strategy.inspect}"
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
