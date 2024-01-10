# frozen_string_literal: true

module Curl
  # Class for CURLing a JSON response
  class Json
    attr_accessor :url

    attr_writer :compressed, :request_headers, :symbolize_names

    attr_reader :code, :json, :headers

    def to_data
      {
        url: @url,
        code: @code,
        json: @json,
        headers: @headers
      }
    end

    ##
    ## Create a new Curl::Json page object
    ##
    ## @param      url         [String] The url to curl
    ## @param      headers     [Hash] The headers to send
    ## @param      compressed  [Boolean] Expect compressed results
    ##
    ## @return     [Curl::Json] Curl::Json object with url, code, parsed json, and response headers
    ##
    def initialize(url, options = {})
      @url = url
      @request_headers = options[:headers]
      @compressed = options[:compressed]
      @symbolize_names = options[:symbolize_names]

      @curl = TTY::Which.which('curl')
    end

    def curl
      page = curl_json

      raise "Error retrieving #{url}" if page.nil? || page.empty?

      @url = page[:url]
      @code = page[:code]
      @json = page[:json]
      @headers = page[:headers]
    end

    def path(path, json = @json)
      parts = path.split(/./)
      target = json
      parts.each do |part|
        if part =~ /(?<key>[^\[]+)\[(?<int>\d+)\]/
          target = target[key][int.to_i]
        else
          target = target[part]
        end
      end

      target
    end

    private

    ##
    ## Curl the JSON contents
    ##
    ## @param      url         [String] The url
    ## @param      headers     [Hash] The headers to send
    ## @param      compressed  [Boolean] Expect compressed results
    ##
    ## @return     [Hash] hash of url, code, headers, and parsed json
    ##
    def curl_json
      flags = 'SsLi'
      agents = [
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.1',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.3',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.'
      ]

      headers = @headers.nil? ? '' : @headers.map { |h, v| %(-H "#{h}: #{v}") }.join(' ')
      compress = @compressed ? '--compressed' : ''
      source = `#{@curl} -#{flags} #{compress} #{headers} '#{@url}' 2>/dev/null`
      agent = 0
      while source.nil? || source.empty?
        source = `#{@curl} -#{flags} #{compress} -A "#{agents[agent]}" #{headers} '#{@url}' 2>/dev/null`
        break if agent >= agents.count - 1
      end

      return false if source.nil? || source.empty?

      source.strip!

      headers = {}
      lines = source.split(/\r\n/)
      code = lines[0].match(/(\d\d\d)/)[1]
      lines.shift
      lines.each_with_index do |line, idx|
        if line =~ /^([\w-]+): (.*?)$/
          m = Regexp.last_match
          headers[m[1]] = m[2]
        else
          source = lines[idx..].join("\n")
          break
        end
      end

      json = source.strip.force_encoding('utf-8')
      begin
        json.gsub!(/[\u{1F600}-\u{1F6FF}]/, '')
        { url: @url, code: code, headers: headers, json: JSON.parse(json, symbolize_names: @symbolize_names) }
      rescue StandardError
        { url: @url, code: code, headers: headers, json: nil }
      end
    end
  end
end
