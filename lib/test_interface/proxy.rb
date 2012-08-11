require 'sender'
require 'test_interface/enforcer'

module TestInterface

  class Proxy

    def initialize(interface, subject)
      @interface = interface
      @subject = subject
      @interface.ensure_valid_for_subject(subject)
      @enforcer = Enforcer.new(interface, subject)
    end

    private

    def method_missing(method, *args)
      @enforcer.enforce(method, args, __sender__)
    end

  end

end