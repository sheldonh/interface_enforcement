require 'interface_enforcement/constraint'

module InterfaceEnforcement

  class MethodContract

    UNCONSTRAINED_METHOD = {args: Constraint::UNCONSTRAINED_TYPE, returns: Constraint::UNCONSTRAINED_TYPE}

    def initialize(specification)
      specification = UNCONSTRAINED_METHOD if specification == :allowed
      set_args_constraint(specification[:args])
      set_return_value_constraint(specification[:returns])
      set_exception_constraint(specification[:exceptions])
    end

    def allows_args?(args)
      @args_constraint.allows?(args)
    end

    def allows_return_value?(return_value)
      @return_value_constraint.allows?(return_value)
    end

    def allows_exception?(exception)
      @exception_constraint.allows?(exception)
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
