# frozen_string_literal: true

module Curl
  # Class for CURLing a JSON response
  class Json
    attr_reader :url, :code, :json, :headers

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
    def initialize(url, headers: nil, compressed: false, symbolize_names: false)
      @curl = TTY::Which.which('curl')
      page = curl_json(url, headers: headers, compressed: compressed, symbolize_names: symbolize_names)
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
    def curl_json(url, headers: nil, compressed: false, symbolize_names: false)
      flags = 'SsLi'
      agent = ['Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3_3 like Mac OS X; en-us)',
               'AppleWebKit/533.17.9 (KHTML, like Gecko)',
               'Version/5.0.2 Mobile/8J2 Safari/6533.18.5'].join(' ')
      headers = headers.nil? ? '' : headers.map { |h, v| %(-H "#{h}: #{v}") }.join(' ')
      compress = compressed ? '--compressed' : ''
      source = `#{@curl} -#{flags} #{compress} #{headers} '#{url}' 2>/dev/null`
      source = `#{@curl} -#{flags} #{compress} -A "#{agent}" #{headers} '#{url}' 2>/dev/null` if source.nil? || source.empty?

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

      json.gsub!(/[\u{1F600}-\u{1F6FF}]/, '')

      { url: url, code: code, headers: headers, json: JSON.parse(json, symbolize_names: symbolize_names) }
    rescue StandardError => e
      warn e
      warn e.backtrace
      nil
    end
  end
end
