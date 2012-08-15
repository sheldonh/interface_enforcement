class Subject
  def get
    @knowledge || "the default"
  end

  def set(something)
    @knowledge = something
  end

  protected

  def protected_method
  end

  private

  def private_method
  end
end

class Descendant < Subject
end

