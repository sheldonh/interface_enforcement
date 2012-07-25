class InterfaceEnforcer

  class Violation < RuntimeError; end
  class MethodViolation < Violation; end
  class ReturnViolation < Violation; end

  class MethodContract

    def initialize(constraints)
      if constraints == :allowed
        @returns = unconstrained_rule
      else
        @returns = constraints[:returns]
      end
    end

    def valid_return_value?(return_value)
      return_value_rule.call(return_value)
    end

    private

    def return_value_rule
      if @returns.is_a?(Proc)
        @returns
      else
        constrained_return_type_rule
      end
    end

    def constrained_return_type_rule
      ->(o) { o.is_a?(@returns) }
    end

    def unconstrained_rule
      ->(o) { true }
    end

  end

  def initialize(contract)
    @contracts = contract.inject({}) do |memo, (method, constraints)|
      memo[method] = MethodContract.new(constraints)
      memo
    end
  end

  def wrap(subject)
    @subject = subject
    self
  end

  private

  def method_missing(method, *args)
    @method, @args = method, args
    constrain_method_invocation
    invoke_method
    constrain_return_value
    @return_value
  end

  def constrain_method_invocation
    @contracts.include?(@method) or raise MethodViolation
  end

  def invoke_method
    @return_value = @subject.public_send(@method, *@args)
  end

  def constrain_return_value
    @contracts[@method].valid_return_value?(@return_value) or raise ReturnViolation
  end

end
