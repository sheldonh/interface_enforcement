class InterfaceEnforcer

  class Violation < RuntimeError; end
  class MethodViolation < Violation; end
  class ReturnViolation < Violation; end

  def initialize(contract)
    @contract = contract
  end

  def attach(subject)
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
    method_contract or raise MethodViolation
  end

  def invoke_method
    @return_value = @subject.public_send(@method, *@args)
  end

  def constrain_return_value
    if constrained_return_type
      constrain_return_value_type
    end
  end

  def constrained_return_type
    if method_contract.respond_to?(:include?) and method_contract.include?(:returns)
      method_contract[:returns]
    end
  end

  def constrain_return_value_type
    if constrained_return_type.is_a?(Proc)
      constrained_return_type.call(@return_value) or raise ReturnViolation
    else
      @return_value.is_a?(constrained_return_type) or raise ReturnViolation
    end
  end

  def method_contract
    @contract[@method]
  end

end
