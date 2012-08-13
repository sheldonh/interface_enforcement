module InterfaceEnforcement

  class AccessControl

    def initialize(subject, method_to_invoke)
      @subject = subject
      @method_to_invoke = method_to_invoke
    end

    def allows?(sender, method)
      @sender, @method = sender, method
      method_exists? and privacy_honoured? and protection_honoured?
    end

    private

    def method_exists?
      @subject.methods.include? @method_to_invoke
    end

    def privacy_honoured?
      !private_method? or subject_is_sender?
    end

    def private_method?
      @subject.private_methods.include? @method_to_invoke
    end

    def subject_is_sender?
      @subject.object_id == @sender.object_id
    end

    def protection_honoured?
      !protected_method? or subject_is_ancestor_of_sender?
    end

    def protected_method?
      @subject.protected_methods.include?(@method_to_invoke)
    end

    def subject_is_ancestor_of_sender?
      sender_ancestors = @sender.class.ancestors - @sender.class.included_modules
      sender_ancestors.include? @subject.class
    end

  end

end
