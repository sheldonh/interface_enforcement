module TestInterface

  class Violation < RuntimeError; end
  class ArgumentViolation < Violation; end
  class ArgumentCountViolation < ArgumentViolation; end
  class ArgumentRuleViolation < ArgumentViolation; end
  class ArgumentTypeViolation < ArgumentViolation; end
  class ExceptionViolation < Violation; end
  class MethodViolation < Violation; end
  class ReturnViolation < Violation; end

end
