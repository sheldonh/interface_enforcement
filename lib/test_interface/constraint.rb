require 'test_interface/constraint/enumeration'
require 'test_interface/constraint/none'
require 'test_interface/constraint/open'
require 'test_interface/constraint/rule'
require 'test_interface/constraint/type'

module TestInterface

  module Constraint

    UNCONSTRAINED_TYPE = :any

    def self.build(specification, *builders)
      constraint = builders.detect do |builder|
        send("try_build_#{builder}", specification)
      end
      constraint or raise "unknown constraint specification #{specification.inspect}"
    end

    def self.try_build_any(specification)
      Constraint::Open.new if specification.nil? or specification == UNCONSTRAINED_TYPE
    end

    def self.try_build_enum(specification)
      Constraint::Enumeration.new(specification) if specification.is_a?(Enumerable)
    end

    def self.try_build_enum_of_one(specification)
      Constraint::Enumeration.new([ specification ]) if specification.is_a?(Module)
    end

    def self.try_build_none(specification)
      Constraint::None.new if specification == :none
    end

    def self.try_build_rule(specification)
      Constraint::Rule.new(specification) if specification.is_a?(Proc)
    end

    def self.try_build_type(specification)
      Constraint::Type.new(specification) if specification.is_a?(Module)
    end

  end

end
