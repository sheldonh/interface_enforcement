class Subject
  def get
    @knowledge || "the default"
  end

  def set(something)
    @knowledge = something
  end

  def ignore(*args)
    args
  end

  def expose_secret
    private_method
  end

  protected

  def protected_method
    "a shared secret"
  end

  private

  def private_method
    "a secret"
  end
end

module SubjectSharing
  def initialize(subject)
    @subject = subject
  end

  def shared_secret
    @subject.protected_method
  end
end

class Descendant < Subject
  include SubjectSharing
end

class NonDescendant
  include SubjectSharing
end

