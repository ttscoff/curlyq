# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyTagsTest < Test::Unit::TestCase
  include CurlyQHelpers

  def setup
  end

  def test_json    
    result = curlyq('json', 'https://brettterpstra.com/scripts/giveaways_wrapper.cgi?v=203495&giveaway=hazel2023&action=count')
    json = JSON.parse(result)

    assert_equal(json.class, Hash, 'Single result should be a hash')
    assert_equal(286, json['json']['total'], 'json.total should match 286')
  end

  def test_query
    result1 = curlyq('json', '-q', 'total', 'https://brettterpstra.com/scripts/giveaways_wrapper.cgi?v=203495&giveaway=hazel2023&action=count')
    result2 = curlyq('json', '-q', 'json.total', 'https://brettterpstra.com/scripts/giveaways_wrapper.cgi?v=203495&giveaway=hazel2023&action=count')
    json1 = JSON.parse(result1)
    json2 = JSON.parse(result2)

    assert_equal(286, json1, 'Should be 286')
    assert_equal(286, json2, 'Including json in dot path should yeild same result')
  end
end
