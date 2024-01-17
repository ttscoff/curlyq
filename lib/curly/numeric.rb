# Numeric helpers
class ::Numeric
  ##
  ## Return an array version of self
  ##
  ## @return     [Array] self enclosed in an array
  ##
  def ensure_array
    [self]
  end
end
