# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyQScrapeTest < Test::Unit::TestCase
  include CurlyQHelpers

  def setup
  end

  def test_scrape
    result = curlyq('scrape', '-b', 'firefox', '-q', 'links[rel=me&content*=mastodon][0]', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)

    assert_match(/Mastodon/, json['content'], 'Should have retrieved a Mastodon link')
  end
end
