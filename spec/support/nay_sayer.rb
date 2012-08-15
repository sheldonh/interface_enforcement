class NaySayer

  def method_missing(method, *args)
    method.to_s.end_with?('?') ? false : nil
  end

end