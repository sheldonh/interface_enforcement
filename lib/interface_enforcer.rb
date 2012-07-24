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
    if have_return_value_constraint?
      return_value_constraint_rule.call(@return_value) or raise ReturnViolation
    end
  end

  def have_return_value_constraint?
    method_contract.respond_to?(:include?) and method_contract.include?(:returns)
  end

  def return_value_constraint_rule
    if return_value_constraint.is_a?(Proc)
      return_value_constraint
    else
      proc_for_return_value_type_constraint
    end
  end

  def proc_for_return_value_type_constraint
    ->(o) { o.is_a?(return_value_constraint) }
  end

  def return_value_constraint
    method_contract[:returns]
  end

  def method_contract
    @contract[@method]
  end

end
