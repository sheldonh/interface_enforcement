module TestInterface

  class Violation < RuntimeError; end
  class ArgumentViolation < Violation; end
  class ArgumentCountViolation < ArgumentViolation; end
  class ArgumentTypeViolation < ArgumentViolation; end
  class MethodViolation < Violation; end
  class ReturnViolation < Violation; end

end
