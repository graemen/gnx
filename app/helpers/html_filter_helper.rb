module HtmlFilterHelper
  ALLOWED_SUBJECT_TAGS = %w[b u i s].freeze
  ALLOWED_CONTENT_TAGS = %w[a img b u i s p pre ul li].freeze
  ALLOWED_CONTENT_ATTRIBUTES = {
    "a" => ["href"],
    "img" => ["src"],
    "p" => ["align"]
  }.freeze

  def sanitize_subject(text)
    return "" if text.blank?
    scrubber = Loofah::Scrubbers::Strip.new
    fragment = Loofah.fragment(text)
    fragment.scrub!(SubjectScrubber.new)
    fragment.to_s
  end

  def sanitize_body(text)
    return "" if text.blank?
    fragment = Loofah.fragment(text)
    fragment.scrub!(ContentScrubber.new)
    fragment.to_s
  end

  class SubjectScrubber < Loofah::Scrubber
    def initialize
      @direction = :bottom_up
    end

    def scrub(node)
      return CONTINUE if node.text?
      if node.element?
        unless HtmlFilterHelper::ALLOWED_SUBJECT_TAGS.include?(node.name.downcase)
          node.before(node.children)
          node.remove
          return STOP
        end
        # Remove all attributes from subject tags
        node.attribute_nodes.each(&:remove)
      end
      CONTINUE
    end
  end

  class ContentScrubber < Loofah::Scrubber
    def initialize
      @direction = :bottom_up
    end

    def scrub(node)
      return CONTINUE if node.text?
      if node.element?
        unless HtmlFilterHelper::ALLOWED_CONTENT_TAGS.include?(node.name.downcase)
          node.before(node.children)
          node.remove
          return STOP
        end
        # Remove disallowed attributes
        allowed_attrs = HtmlFilterHelper::ALLOWED_CONTENT_ATTRIBUTES[node.name.downcase] || []
        node.attribute_nodes.each do |attr|
          if allowed_attrs.include?(attr.name.downcase)
            # Block dangerous URI schemes in href/src
            if %w[href src].include?(attr.name.downcase)
              attr.remove if attr.value =~ /\A\s*(javascript|data|vbscript):/i
            end
          else
            attr.remove
          end
        end
      end
      CONTINUE
    end
  end
end
