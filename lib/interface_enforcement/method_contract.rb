require 'interface_enforcement/constraint'

module InterfaceEnforcement

  class MethodContract

    UNCONSTRAINED_METHOD = {:args => :any, :returns => :any, :exceptions => :any}

    # TODO convert current consumers to use #new instead (probably requiring course-grained constraint builders)
    def self.build(specification, builder = Constraint)
      specification = UNCONSTRAINED_METHOD if specification == :allowed
      new(builder.build_args_constraint(specification[:args]),
          builder.build_exception_constraint(specification[:exceptions]),
          builder.build_return_value_constraint(specification[:returns]))
    end

    def initialize(args_constraint, exception_constraint, return_value_constraint)
      @args_constraint = args_constraint
      @return_value_constraint = return_value_constraint
      @exception_constraint = exception_constraint
    end

    attr_reader :args_constraint, :return_value_constraint, :exception_constraint

    def allows_args?(args)
      @args_constraint.allows?(args)
    end

    def allows_return_value?(return_value)
      @return_value_constraint.allows?(return_value)
    end

    def allows_exception?(exception)
      @exception_constraint.allows?(exception)
    end

  end

end
