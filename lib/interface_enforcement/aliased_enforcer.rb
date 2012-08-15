require 'interface_enforcement/enforcer'
require 'interface_enforcement/violation'

module InterfaceEnforcement

  class AliasedEnforcer < Enforcer

    # TODO This needs Josh Cheek's deject gem
    def initialize(interface, subject, alias_prefix = nil, access_control = AccessControl)
      super(interface, subject)
      @access_control = access_control
      @alias_prefix = alias_prefix
    end

    private

    def method_to_invoke
      :"#{@alias_prefix}#{@method}"
    end

  end

end