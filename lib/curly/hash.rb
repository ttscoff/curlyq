# frozen_string_literal: true

# Hash helpers
class ::Hash
  def to_data(url: nil, clean: false)
    if key?(:body_links)
      {
        url: self[:url] || url,
        code: self[:code],
        headers: self[:headers],
        meta: self[:meta],
        meta_links: self[:links],
        head: clean ? self[:head]&.strip&.clean : self[:head],
        body: clean ? self[:body]&.strip&.clean : self[:body],
        source: clean ? self[:source]&.strip&.clean : self[:source],
        title: self[:title],
        description: self[:description],
        links: self[:body_links],
        images: self[:body_images]
      }
    else
      self
    end
  end

  def to_html
    if key?(:source)
      self[:source]
    end
  end

  def get_value(query)
    return nil if self.empty?
    stringify_keys!

    query.split('.').inject(self) do |v, k|
      if v.is_a? Array
        return v.map { |el| el.get_value(k) }
      end
      # k = k.to_i if v.is_a? Array
      next unless v.key?(k)

      v.fetch(k)
    end
  end

  # Extract data using a dot-syntax path
  #
  # @param      path  [String] The path
  #
  # @return     Result of path query
  #
  def dot_query(path, root = nil, full_tag: true)
    res = stringify_keys
    res = res[root] unless root.nil?

    unless path =~ /\[/
      return res.get_value(path)
    end

    path.gsub!(/\[(.*?)\]/) do
      inter = Regexp.last_match(1).gsub(/\./, '%')
      "[#{inter}]"
    end

    enumerate = false
    out = []
    q = path.split(/(?<![\d.])\./)

    while q.count.positive?
      pth = q.shift
      pth.gsub!(/%/, '.')

      return nil if res.nil?

      unless pth =~ /\[/
        return res.get_value(pth)
      end

      el = Regexp.last_match(1) if pth =~ /\[([0-9,.]+)?\]/
      pth.sub!(/\[([0-9,.]+)?\]/, '')

      ats = []
      at = []
      while pth =~ /\[[+&,]?[\w.]+( *[\^*$=<>]=? *\w+)?/
        m = pth.match(/\[(?<com>[,+&])? *(?<key>[\w.]+)( *(?<op>[\^*$=<>]{1,2}) *(?<val>[^,&\]]+))? */)

        comp = [m['key'], m['op'], m['val']]
        case m['com']
        when ','
          ats.push(comp)
          at = []
        else
          at.push(comp)
        end

        pth.sub!(/\[(?<com>[,&+])? *(?<key>[\w.]+)( *(?<op>[\^*$=<>]{1,2}) *(?<val>[^,&\]]+))?/, '[')
      end
      ats.push(at) unless at.empty?
      pth.sub!(/\[\]/, '')

      res = res[0] if res.is_a?(Array) && res.count == 1
      if ats.empty? && el.nil? && res.is_a?(Array) && res[0]&.key?(pth)
        res.map! { |r| r[pth] }
        next
      end

      res.map!(&:stringify_keys) if res.is_a?(Array) && res[0].is_a?(Hash)
      # if res.is_a?(String) || (res.is_a?(Array) && res[0].is_a?(String))
      #   out.push(res)
      #   next
      # end

      # if res.is_a?(Array) && !pth.nil?
      #   return res.delete_if { |r| !r.key?(pth) }
      # else
      #   return false if el.nil? && ats.empty? && res.is_a?(Hash) && (res.nil? || !res.key?(pth))
      # end
      tag = res
      res = res[pth] unless pth.nil? || pth.empty?

      pth = ''

      return false if res.nil?

      if ats.count.positive?
        while ats.count.positive?
          atr = ats.shift
          res = [res] if res.is_a?(Hash)
          res.each do |r|
            out.push(full_tag ? tag : r) if evaluate_comp(r, atr)
          end
        end
      else
        out = res
      end

      out = out.get_value(pth) unless pth.nil?

      if el.nil? && out.is_a?(Array) && out[0].is_a?(Hash)
        out.map! { |o|
          o.stringify_keys
          # o.key?(pth) ? o[pth] : o
        }
      elsif out.is_a?(Array) && el =~ /^[\d.,]+$/
        out = out[eval(el)]
      end
      res = out
    end

    out = out[0] if out&.count == 1
    out
  end

  def array_match(array, key, comp)
    keep = false
    array.each do |el|
      keep = case comp
             when /^\^/
               key =~ /^#{el}/i ? true : false
             when /^\$/
               key =~ /#{el}$/i ? true : false
             when /^\*/
               key =~ /#{el}/i ? true : false
             else
               key =~ /^#{el}$/i ? true : false
             end
      break if keep
    end
    keep
  end

  ##
  ## Evaluate a comparison
  ##
  ## @param      r     [Hash] hash of source elements and
  ##                   comparison operators
  ## @param      atr   [Array] Array of arrays conaining [attribute,comparitor,value]
  ##
  ## @return     [Boolean] whether the comparison passes or fails
  ##
  def evaluate_comp(r, atr)
    keep = true

    r = r.symbolize_keys

    atr.each do |a|
      key = a[0].to_sym
      val = if a[2] =~ /^\d+$/
              a[2].to_i
            elsif a[2] =~ /^\d+\.\d+$/
              a[2].to_f
            else
              a[2]
            end
      r = r.get_value(key.to_s) if key.to_s =~ /\./

      if r.is_a?(Hash)
        return r.key?(key) && !r[key].nil? && !r[key].empty? if val.nil?
      elsif r.is_a?(String) && val.nil?
        return r.nil? ? false : true
      end

      if r.nil?
        keep = false
      elsif r.is_a?(Array)
        valid = r.filter do |k|
          if k.is_a? Array
            array_match(k, a[2], a[1])
          else
            case a[1]
            when /^\^/
              k =~ /^#{a[2]}/i ? true : false
            when /^\$/
              k =~ /#{a[2]}$/i ? true : false
            when /^\*/
              k =~ /#{a[2]}/i ? true : false
            else
              k =~ /^#{a[2]}$/i ? true : false
            end
          end
        end

        keep = valid.count.positive?
      elsif val.is_a?(Numeric) && a[1] =~ /^[<>=]{1,2}$/
        k = r.to_i
        comp = a[1] =~ /^=$/ ? '==' : a[1]
        keep = eval("#{k}#{comp}#{val}")
      else
        v = r.is_a?(Hash) ? r[key] : r
        if v.is_a? Array
          keep = array_match(v, a[2], a[1])
        else
          keep = case a[1]
                 when /^\^/
                   v =~ /^#{a[2]}/i ? true : false
                 when /^\$/
                   v =~ /#{a[2]}$/i ? true : false
                 when /^\*/
                   v =~ /#{a[2]}/i ? true : false
                 else
                   v =~ /^#{a[2]}$/i ? true : false
                 end
        end
      end

      return false unless keep
    end

    keep
  end

  ##
  ## Test if a tag contains an attribute matching filter queries
  ##
  ## @param      tag_name    [String] The tag name
  ## @param      classes     [String] The classes to match
  ## @param      id          [String] The id attribute to
  ##                         match
  ## @param      attribute   [String] The attribute
  ## @param      operator    [String] The operator, <>= *=
  ##                         $= ^=
  ## @param      value       [String] The value to match
  ## @param      descendant  [Boolean] Check descendant tags
  ##
  def tag_match(tag_name, classes, id, attribute, operator, value, descendant: false)
    tag = self
    keep = true

    keep = false if tag_name && !tag['tag'] =~ /^#{tag_name}$/i

    if tag.key?('attrs') && tag['attrs']
      if keep && id
        tag_id = tag['attrs'].filter { |a| a['key'] == 'id' }.first['value']
        keep = tag_id && tag_id =~ /#{id}/i
      end

      if keep && classes
        cls = tag['attrs'].filter { |a| a['key'] == 'class' }.first
        if cls
          all = true
          classes.each { |c| all = cls['value'].include?(c) }
          keep = all
        else
          keep = false
        end
      end

      if keep && attribute
        attributes = tag['attrs'].filter { |a| a['key'] =~ /^#{attribute}$/i }
        any = false
        attributes.each do |a|
          break if any

          any = case operator
                when /^*/
                  a['value'] =~ /#{value}/i
                when /^\^/
                  a['value'] =~ /^#{value}/i
                when /^\$/
                  a['value'] =~ /#{value}$/i
                else
                  a['value'] =~ /^#{value}$/i
                end
        end
        keep = any
      end
    end

    return false if descendant && !keep

    if !descendant && tag.key?('tags')
      tags = tag['tags'].filter { |t| t.tag_match(tag_name, classes, id, attribute, operator, value) }
      tags.count.positive?
    else
      keep
    end
  end

  # Turn all keys into symbols
  #
  # If the hash has both a string and a symbol for key,
  # keep the symbol value, discarding the string value
  #
  # @return     [Hash] a copy of the hash where all its
  #             keys are strings
  #
  def symbolize_keys
    each_with_object({}) do |(k, v), hsh|
      next if k.is_a?(String) && key?(k.to_sym)

      hsh[k.to_sym] = v.is_a?(Hash) ? v.symbolize_keys : v
    end
  end

  # Turn all keys into strings
  #
  # If the hash has both a string and a symbol for key,
  # keep the string value, discarding the symbol value
  #
  # @return     [Hash] a copy of the hash where all its
  #             keys are strings
  #
  def stringify_keys
    each_with_object({}) do |(k, v), hsh|
      next if k.is_a?(Symbol) && key?(k.to_s)

      hsh[k.to_s] = v.is_a?(Hash) ? v.stringify_keys : v
    end
  end

  def stringify_keys!
    replace stringify_keys
  end
end
