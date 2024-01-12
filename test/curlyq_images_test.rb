# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyQImagesTest < Test::Unit::TestCase
  include CurlyQHelpers

  def test_images_query
    result = curlyq('images', '-t', 'img', '-q', '[alt$=screenshot]', 'https://brettterpstra.com/2024/01/08/keyboard-maestro-giveaway/')
    json = JSON.parse(result)

    assert(json.count == 1, 'Should have found 1 image')
    assert_match(/Keyboard Maestro screenshot/, json[0]['alt'], 'Should match Keyboard Meastro screenshot')
  end

  def test_images_type
    result = curlyq('images', '-t', 'srcset', 'https://brettterpstra.com/')
    json = JSON.parse(result)

    assert(json.count.positive?, 'Should have found at least 1 image')
  end
end
