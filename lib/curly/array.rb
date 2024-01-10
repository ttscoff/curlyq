# frozen_string_literal: true

# Array helpers
class ::Array
  ##
  ## Remove extra spaces from each element of an array of
  ## strings
  ##
  ## @return     [Array] cleaned array
  ##
  def clean
    map(&:clean)
  end

  ##
  ## @see #clean
  ##
  def clean!
    replace clean
  end

  ##
  ## Strip HTML tags from each element of an array of
  ## strings
  ##
  ## @return     [Array] array of strings with HTML tags removed
  ##
  def strip_tags
    map(&:strip_tags)
  end

  ##
  ## Destructive version of #strip_tags
  ##
  ## @see #strip_tags
  ##
  def strip_tags!
    replace strip_tags
  end

  ##
  ## Remove duplicate links from an array of link objects
  ##
  ## @return     [Array] deduped array of link objects
  ##
  def dedup_links
    used = []
    good = []
    each do |link|
      href = link[:href].sub(%r{/$}, '')
      next if used.include?(href)

      used.push(href)
      good.push(link)
    end

    good
  end

  ##
  ## Destructive version of #dedup_links
  ##
  ## @see #dedup_links
  ##
  def dedup_links!
    replace dedup_links
  end

  ##
  ## Convert and execute a dot-syntax query on the array
  ##
  ## @param      path  [String]  The dot-syntax path
  ##
  ## @return     [Array] Matching elements
  ##
  def dot_query(path)
    output = []
    if path =~ /^\[([\d+.])\]\.?/
      int = Regexp.last_match(1)
      path.sub!(/^\[[\d.]+\]\.?/, '')
      items = self[eval(int)]
    else
      items = self
    end

    if items.is_a? Hash
      output = items.dot_query(path)
    else
      items.each do |item|
        res = item.is_a?(Hash) ? item.stringify_keys : item
        out = []
        q = path.split(/(?<![\d.])\./)
        q.each do |pth|
          el = Regexp.last_match(1) if pth =~ /\[([0-9,.]+)\]/
          pth.sub!(/\[([0-9,.]+)\]/, '')
          ats = []
          at = []
          while pth =~ /\[[+&,]?\w+ *[\^*$=<>]=? *\w+/
            m = pth.match(/\[(?<com>[,+&])? *(?<key>\w+) *(?<op>[\^*$=<>]{1,2}) *(?<val>\w+) */)
            comp = [m['key'], m['op'], m['val']]
            case m['com']
            when ','
              ats.push(comp)
              at = []
            else
              at.push(comp)
            end

            pth.sub!(/\[(?<com>[,&+])? *(?<key>\w+) *(?<op>[\^*$=<>]{1,2}) *(?<val>\w+)/, '[')
          end
          ats.push(at) unless at.empty?
          pth.sub!(/\[\]/, '')

          return false if el.nil? && ats.empty? && !res.key?(pth)

          res = res[pth] unless pth.empty?

          while ats.count.positive?
            atr = ats.shift

            keepers = res.filter do |r|
              evaluate_comp(r, atr)
            end
            out.concat(keepers)
          end

          out = out[eval(el)] if out.is_a?(Array) && el =~ /^[\d.,]+$/
        end
        output.push(out)
      end
    end
    output
  end
end
