# frozen_string_literal: true

class ::Array
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

  # def css_query(path, first_level: false)
  #   res = map(&:stringify_keys)
  #   q = path.strip.split(/([ >])+/)
  #   sep = nil

  #   while q.count.positive?
  #     el = q.shift
  #     id, classes, at, op, val = nil
  #     if el =~ /\[(?<attr>\w+) *(?<op>[*^$]?=) *(?<val>.*?)\]/
  #       m = Regexp.last_match
  #       at = m['attr']
  #       op = m['op']
  #       val = m['val']
  #       el.sub!(/\[.*?\]/)
  #     end

  #     if el =~ /^(?<tag>\w+)?(?<spec>(?:#\w+)|(?:\.\w+)+)?/
  #       m = Regexp.last_match
  #       t = m['tag']
  #       spec = m['spec']
  #       raise "Invalid CSS path: #{el}" unless t || spec

  #       if spec
  #         if spec =~ /^#(?<val>[^.]+)/
  #           id = Regexp.last_match['val']
  #           spec.sub!(/^#[^.]+/, '')
  #         end

  #         classes = spec.split(/\./).delete_if(&:nil?)
  #       end
  #     end

  #     out = []

  #     res.each do |h|
  #       if sep.nil? || sep =~ /^ +$/
  #         out << h if h.tag_match(t, classes, id, at, op, val)
  #       elsif h.tag_match(t, classes, id, at, op, val, descendant: true)
  #         out << h
  #       end
  #     end

  #     sep = q.shift
  #   end

  #   out.delete_if { |r| r.tag_match }
  # end
end
