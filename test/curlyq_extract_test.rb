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

  def test_extract_inclusive
    result = curlyq('extract', '-i', '-b', 'Adding', '-a', 'accessing the source.', 'https://stackoverflow.com/questions/52428409/get-fully-rendered-html-using-selenium-webdriver-and-python')
    json = JSON.parse(result)

    assert_match(/^Adding <code>time.sleep\(10\)<\/code>.*?accessing the source.$/, json[0], 'Match should be found and include the before and after strings')
  end

  def test_extract_exclusive
    result = curlyq('extract', '-b', 'Adding', '-a', 'accessing the source.', 'https://stackoverflow.com/questions/52428409/get-fully-rendered-html-using-selenium-webdriver-and-python')
    json = JSON.parse(result)

    assert_match(/^ <code>time.sleep\(10\)<\/code>.*?when I was $/, json[0], 'Match should be found and not include the before and after strings')
  end

  def test_extract_regex_inclusive
    result = curlyq('extract', '-ri', '-b', '.dding <', '-a', 'accessing.*?source.', 'https://stackoverflow.com/questions/52428409/get-fully-rendered-html-using-selenium-webdriver-and-python')
    json = JSON.parse(result)

    assert_match(/^Adding <code>time.sleep\(10\)<\/code>.*?accessing the source.$/, json[0], 'Match should be found and include the before and after strings')
  end

  def test_extract_regex_exclusive
    result = curlyq('extract', '-r', '-b', '.dding <', '-a', 'accessing.*?source.', 'https://stackoverflow.com/questions/52428409/get-fully-rendered-html-using-selenium-webdriver-and-python')
    json = JSON.parse(result)

    assert_match(/^code>time.sleep\(10\)<\/code>.*?when I was $/, json[0], 'Match should be found and not include the before and after strings')
  end
end
