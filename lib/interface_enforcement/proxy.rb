require 'deject'
require 'sender'
require 'interface_enforcement/enforcer'

module InterfaceEnforcement

  class Proxy

    Deject self
    dependency(:enforcer) do |proxy|
      proxy.instance_exec { Enforcer.new(@interface, @subject) }
    end

    def self.proxy(interface, subject)
      new(interface, subject)
    end

    def initialize(interface, subject)
      @interface = interface
      @subject = subject
    end

    def method_missing(method, *args)
      enforcer.enforce(method, args, __sender__)
    end

  end

end