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
    enforce_method_allowed
    @return_value = @subject.public_send(@method, *@args)
    if @contract[@method].respond_to?(:include?) and @contract[@method].include?(:return)
      @return_value.is_a?(@contract[@method][:return]) or raise ReturnViolation
    end
    @return_value
  end

  def enforce_method_allowed
    @contract[@method] or raise MethodViolation
  end

end
