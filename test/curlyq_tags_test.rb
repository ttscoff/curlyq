# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyQTagsTest < Test::Unit::TestCase
  include CurlyQHelpers

  def setup
  end

  def test_tags
    result = curlyq('tags', '--search', '#main .post h3', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)

    assert_equal(Array, json.class, 'Should be an array of matches')
    assert_equal(6, json.count, 'Should be six results')
  end

  def test_clean
    result = curlyq('tags', '--search', '#main section.related', '--clean', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)

    assert_equal(Array, json.class, 'Should be a single Array')
    assert_equal(1, json.count, 'Should be one element')
    assert_match(%r{Last.fm</h5></a></li>}, json[0]['source'], 'Should have matched #whats-next')
  end

  def test_query
    result = curlyq('tags', '--search', '#main .post h3', '-q', '[attrs.id*=what].source', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)
    assert_equal(Array, json.class, 'Should be an array')
    assert_match(%r{^<h3 id="whats-next">What’s Next</h3>$}, json[0], 'Should have returned just source')
  end
end
