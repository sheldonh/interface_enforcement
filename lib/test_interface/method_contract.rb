require 'test_interface/constraint'
require 'test_interface/violation'

module TestInterface

  class MethodContract

    UNCONSTRAINED_METHOD = {args: Constraint::UNCONSTRAINED_TYPE, returns: Constraint::UNCONSTRAINED_TYPE}

    def initialize(specification)
      specification = UNCONSTRAINED_METHOD if specification == :allowed
      set_args_constraint(specification[:args])
      set_return_value_constraint(specification[:returns])
      set_exception_constraint(specification[:exceptions])
    end

    def constrain_args(args)
      @args_constraint.constrain(args) or raise ArgumentViolation
    end

    def constrain_return_value(return_value)
      @return_value_constraint.constrain(return_value) or raise ReturnViolation
    end

    def constrain_exception(exception)
      @exception_constraint.constrain(exception) or raise ExceptionViolation
    end

    private

    def set_args_constraint(specification)
      @args_constraint = Constraint.build(specification, :rule, :none, :enum, :enum_of_one, :any)
    end

    def set_return_value_constraint(specification)
      @return_value_constraint = Constraint.build(specification, :rule, :type, :any)
    end

    def set_exception_constraint(specification)
      @exception_constraint = Constraint.build(specification, :rule, :none, :type, :any)
    end

  end

end
