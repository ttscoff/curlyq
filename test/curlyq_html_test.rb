# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyQHtmlTest < Test::Unit::TestCase
  include CurlyQHelpers

  def test_html_search_query
    result = curlyq('html', '-s', '#main article .aligncenter', '-q', 'images[1]', 'https://brettterpstra.com')
    json = JSON.parse(result)

    assert_match(/aligncenter/, json['class'], 'Should have found an image with class "aligncenter"')
  end

  def test_html_query
    result = curlyq('html', '-q', 'meta.title', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')

    assert_match(/Introducing CurlyQ/, result, 'Should have retrived the page title')
  end
end
