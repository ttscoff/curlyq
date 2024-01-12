# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyQHeadlinksTest < Test::Unit::TestCase
  include CurlyQHelpers

  def setup
  end

  def test_headlinks_query
    result = curlyq('headlinks', '-q', '[rel=stylesheet]', 'https://brettterpstra.com')
    json = JSON.parse(result)

    assert_match(/stylesheet/, json['rel'], 'Should have retrieved a single result with rel stylesheet')
    assert_match(/screen\.\d+\.css$/, json['href'], 'Stylesheet should be correct primary stylesheet')
  end

  def test_headlinks
    result = curlyq('headlinks', 'https://brettterpstra.com')
    json = JSON.parse(result)

    assert_equal(Array, json.class, 'Should have an array of results')
    assert(json.count > 1, 'Should have more than one link')
    # assert(json[0].count.positive?)
  end
end
