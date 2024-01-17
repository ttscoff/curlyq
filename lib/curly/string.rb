# frozen_string_literal: true

##
## Remove extra spaces and newlines from a string
##
## @return     [String] cleaned string
##
class ::String
  ## Remove extra spaces and newlines, compress space
  ## between tags
  ##
  ## @return     [String] cleaned string
  ##
  def clean
    gsub(/[\t\n ]+/m, ' ').gsub(/> +</, '><')
  end

  ##
  ## Remove HTML tags from a string
  ##
  ## @return     [String] stripped string
  ##
  def strip_tags
    gsub(%r{</?.*?>}, '')
  end

  ##
  ## Destructive version of #clean
  ##
  ## @see #clean
  ##
  def clean!
    replace clean
  end

  ##
  ## Destructive version of #strip_tags
  ##
  ## @see #strip_tags
  ##
  def strip_tags!
    replace strip_tags
  end

  ##
  ## Convert an image type string to a symbol
  ##
  ## @return     [Symbol] :srcset, :img, :opengraph, :all
  ##
  def normalize_image_type(default = :all)
    case self.to_s
    when /^[sp]/i
      :srcset
    when /^i/i
      :img
    when /^o/i
      :opengraph
    else
      default.is_a?(Symbol) ? default.to_sym : default.normalize_image_type
    end
  end

  ##
  ## Convert a browser type string to a symbol
  ##
  ## @return     [Symbol] :chrome, :firefox
  ##
  def normalize_browser_type(default = :none)
    case self.to_s
    when /^c/i
      :chrome
    when /^f/i
      :firefox
    else
      default.is_a?(Symbol) ? default.to_sym : default.normalize_browser_type
    end
  end

  ##
  ## Convert a screenshot type string to a symbol
  ##
  ## @return     [Symbol] :full_page, :print_page, :visible
  ##
  def normalize_screenshot_type(default = :none)
    case self.to_s
    when /^f/i
      :full_page
    when /^p/i
      :print_page
    when /^v/i
      :visible
    else
      default.is_a?(Symbol) ? default.to_sym : default.normalize_browser_type
    end
  end

  ##
  ## Clean up output and return a single-item array
  ##
  ## @return     [Array] output array
  ##
  def clean_output
    output = ensure_array
    output.clean_output
  end

  ##
  ## Ensure that an object is an array
  ##
  ## @return     [Array] object as Array
  ##
  def ensure_array
    return [self]
  end
end
