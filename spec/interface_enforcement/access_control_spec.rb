require 'spec_helper'

module InterfaceEnforcement

  describe AccessControl do

    it 'disallows access to nonexistent methods' do
      subject = Subject.new
      decision = AccessControl.subject_allows_sender?(subject, self, :nonexistent)
      decision.should be_false
    end

    it 'disallows access to private methods' do
      subject = Subject.new
      decision = AccessControl.subject_allows_sender?(subject, self, :private_method)
      decision.should be_false
    end

    it 'disallows unfamiliar access to protected methods' do
      subject = Subject.new
      decision = AccessControl.subject_allows_sender?(subject, self, :protected_method)
      decision.should be_false
    end

    it 'allows familiar access to protected methods' do
      subject = Subject.new
      descendant = Descendant.new
      decision = AccessControl.subject_allows_sender?(subject, descendant, :protected_method)
      decision.should be_true
    end

    it 'allows internal access to protected methods' do
      subject = Subject.new
      decision = AccessControl.subject_allows_sender?(subject, subject, :protected_method)
      decision.should be_true
    end

    it 'allows access to public methods' do
      subject = Subject.new
      decision = AccessControl.subject_allows_sender?(subject, self, :get)
      decision.should be_true
    end

  end

end