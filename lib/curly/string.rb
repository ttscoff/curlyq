# frozen_string_literal: true

class ::String
  def clean
    gsub(/[\n ]+/m, ' ')
  end

  ##
  ## Convert an image type string to a symbol
  ##
  ## @return     Symbol :srcset, :img, :opengraph, :all
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
  ## @return     Symbol :chrome, :firefox
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
  ## @return     Symbol :full_page, :print_page, :visible
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
end
