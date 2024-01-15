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

  #---------------------------------------------------------
  ## Run a query on array elements
  ##
  ## @param      path [String] dot.syntax path to compare
  ##
  ## @return [Array] elements matching dot query
  ##
  def dot_query(path)
    res = map { |el| el.dot_query(path) }
    res.delete_if { |r| !r }
    res.delete_if(&:empty?)
    res
  end

  def get_value(path)
    res = map { |el| el.get_value(path) }
    res.is_a?(Array) && res.count == 1 ? res[0] : res
  end

  def to_html
    map(&:to_html)
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
end
