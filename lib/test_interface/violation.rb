module TestInterface

  class Violation < RuntimeError; end
  class PrivacyViolation < Violation; end
  class ArgumentViolation < Violation; end
  class ExceptionViolation < Violation; end
  class MethodViolation < Violation; end
  class ReturnViolation < Violation; end

end
