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

  def test_tags
    result = curlyq('tags', '--search', '#main .post h3', '-q', 'attrs[id*=what]', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)

    assert_equal(json.count, 1, 'Should have 1 result')
    assert_match(/whats-next/, json[0]['attrs']['id'], 'Should have matched #whats-next')
  end

  def test_clean
    result = curlyq('tags', '--search', '#main section.related', '--clean', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)

    assert_equal(json.count, 1, 'Should have 1 result')
    assert_match(%r{Last.fm</h5></a></li>}, json[0]['source'], 'Should have matched #whats-next')
  end
end
