class InterfaceEnforcer

  class Violation < RuntimeError; end
  class MethodViolation < Violation; end

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
    enforce_method_allowed
    @subject.send(@method, *@args)
  end

  def enforce_method_allowed
    @contract[@method] == :allowed or raise MethodViolation
  end

end
