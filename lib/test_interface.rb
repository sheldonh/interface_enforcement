require 'test_interface/enforcer'

module TestInterface

  class Violation < RuntimeError; end
  class MethodViolation < Violation; end
  class ReturnViolation < Violation; end

end
