require 'interface_enforcement/constraint/enumeration'
require 'interface_enforcement/constraint/none'
require 'interface_enforcement/constraint/open'
require 'interface_enforcement/constraint/rule'
require 'interface_enforcement/constraint/type'

module InterfaceEnforcement

  module Constraint

    ALL_TYPES = [:any, :enum, :enum_of_one, :none, :rule, :type]

    # TODO use Josh Cheek's deject gem to make the Builder for clean testing, and maybe clean usage as well
    def self.build_args_constraint(specification)
      build(specification, :rule, :none, :enum, :enum_of_one, :any)
    end

    def self.build_return_value_constraint(specification)
      build(specification, :rule, :type, :any)
    end

    def self.build_exception_constraint(specification)
      build(specification, :rule, :none, :type, :any)
    end

    def self.build(specification, *strategies)
      Builder.new(*strategies).build(specification)
    end

    private

    class Builder

      def initialize(*strategies)
        @strategies = strategies
        strategies_must_be_legal
      end

      def build(specification)
        @specification = specification
        @strategies.detect { |strategy| @constraint = try_build(strategy) }
        @constraint or raise ArgumentError, "all strategies gave up on #{@specification.inspect}"
      end

      private

      def strategies_must_be_legal
        @strategies.each do |s|
          ALL_TYPES.include?(s) or raise ArgumentError, "unknown constraint builder strategy #{s.inspect}"
        end
      end

      def try_build(strategy)
        send("build_#{strategy}")
      end

      def build_any
        Constraint::Open.new if @specification.nil? or @specification == :any
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
