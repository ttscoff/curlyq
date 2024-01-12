# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyQLinksTest < Test::Unit::TestCase
  include CurlyQHelpers

  def test_links
    result = curlyq('links', '-q', '[content*=twitter]', 'https://stackoverflow.com/questions/52428409/get-fully-rendered-html-using-selenium-webdriver-and-python')
    json = JSON.parse(result)

    assert(json.count.positive?, 'Should be at least 1 match')
    assert_match(/twitter.com/, json[0]['href'], 'Should be a link to Twitter')
  end
end
