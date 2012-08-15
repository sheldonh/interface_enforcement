module InterfaceEnforcement

  module AccessControl

    def self.subject_allows_sender?(subject, sender, method)
      Relationship.new(sender, subject).allows?(method)
    end

    private

    class Relationship

      def initialize(sender, subject)
        @sender = sender
        @subject = subject
      end

      def allows?(method)
        @method = method
        method_exists? and !private_method? and protection_honoured?
      end

      private

      def method_exists?
        @subject.methods.include? @method
      end

      def private_method?
        #noinspection RubyResolve
        @subject.private_methods.include? @method
      end

      def protection_honoured?
        !protected_method? or subject_is_ancestor_of_sender?
      end

      def protected_method?
        @subject.protected_methods.include?(@method)
      end

      def subject_is_ancestor_of_sender?
        sender_ancestors.include? @subject.class
      end

      def sender_ancestors
        @sender.class.ancestors - @sender.class.included_modules
      end

    end

  end

end
