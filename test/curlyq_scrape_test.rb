# frozen_string_literal: true

require 'json'
require 'yaml'

require 'helpers/curlyq-helpers'
require 'test_helper'

# Tests for tags command
class CurlyQScrapeTest < Test::Unit::TestCase
  include CurlyQHelpers

  def setup
    @screenshot = File.join(File.dirname(__FILE__), 'screenshot_test')
    FileUtils.rm_f("#{@screenshot}.pdf") if File.exist?("#{@screenshot}.pdf")
    FileUtils.rm_f('screenshot_test.png') if File.exist?("#{@screenshot}.png")
    FileUtils.rm_f("#{@screenshot}_full.png") if File.exist?("#{@screenshot}_full.png")
  end

  def teardown
    FileUtils.rm_f("#{@screenshot}.pdf") if File.exist?("#{@screenshot}.pdf")
    FileUtils.rm_f('screenshot_test.png') if File.exist?("#{@screenshot}.png")
    FileUtils.rm_f("#{@screenshot}_full.png") if File.exist?("#{@screenshot}_full.png")
  end

  def test_scrape_firefox
    result = curlyq('scrape', '-b', 'firefox', '-q', 'links[rel=me&content*=mastodon][0]', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)

    assert_equal(Array, json.class, 'Result should be an Array')
    assert_match(/Mastodon/, json[0]['content'], 'Should have retrieved a Mastodon link')
  end

  def test_scrape_chrome
    result = curlyq('scrape', '-b', 'chrome', '-q', 'links[rel=me&content*=mastodon][0]', 'https://brettterpstra.com/2024/01/10/introducing-curlyq-a-pipeline-oriented-curl-helper/')
    json = JSON.parse(result)

    assert_equal(Array, json.class, 'Result should be an Array')
    assert_match(/Mastodon/, json[0]['content'], 'Should have retrieved a Mastodon link')
  end

  def test_screenshot
    curlyq('screenshot', '-b', 'firefox', '-o', @screenshot, '-t', 'print', 'https://brettterpstra.com')
    assert(File.exist?("#{@screenshot}.pdf"), 'PDF Screenshot should exist')

    curlyq('screenshot', '-b', 'chrome', '-o', @screenshot, '-t', 'visible', 'https://brettterpstra.com')
    assert(File.exist?("#{@screenshot}.png"), 'PNG Screenshot should exist')

    curlyq('screenshot', '-b', 'firefox', '-o', "#{@screenshot}_full", '-t', 'full', 'https://brettterpstra.com')
    assert(File.exist?("#{@screenshot}_full.png"), 'PNG Screenshot should exist')
  end
end
