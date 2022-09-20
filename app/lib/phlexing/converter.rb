require "nokogiri"

module Phlexing
  class Converter
    include Helpers

    attr_accessor :html

    def initialize(html)
      @html = html
      @buffer = ""
      handle_node
    end

    def handle_text(node, level, newline = true)
      text = node.text.strip

      if text.length.positive?
        @buffer << indent(level)

        if node.parent.children.length > 1
          @buffer << "text "
        end

        @buffer << double_quote(text)
        @buffer << "\n" if newline
      end
    end

    def handle_erb_element(node, level)
      if node.attributes["interpolated"] && node.text.starts_with?('"')
        @buffer << "text "
      elsif node.attributes["comment"]
        @buffer << "# "
      end

      @buffer << node.text + "\n"
    end

    def handle_element(node, level)
      @buffer << indent(level) + node.name + handle_attributes(node)

      if node.children.any?
        if node.children.one? && node.children.first.is_a?(Nokogiri::XML::Text)
          @buffer << " { "
          handle_text(node.children.first, 0, false)
          @buffer << " }\n"
        else
          @buffer << do_block_start
          handle_children(node, level)
          @buffer << do_block_end(level)
        end
      end
    end

    def handle_children(node, level)
      node.children.each do |child|
        handle_node(child, level + 1)
      end
    end

    def handle_attributes(node)
      return "" if node.attributes.keys.none?

      b = ""

      node.attributes.values.each do |attribute|
        b << attribute.name.gsub("-", "_")
        b << ": "
        b << double_quote(attribute.value)
        b << ", " if node.attributes.values.last != attribute
      end

      if node.children.any?
        "(#{b.strip}) "
      else
        " #{b.strip}"
      end
    end

    def handle_node(node = parsed, level = 0)
      case node
      when Nokogiri::XML::Text
        handle_text(node, level)
      when Nokogiri::XML::Element
        if node.name == "erb"
          handle_erb_element(node, level)
        else
          handle_element(node, level)
        end

        @buffer << "\n" if level == 1
      when Nokogiri::HTML4::DocumentFragment
        handle_children(node, level)
      else
        @buffer << "UNKNOWN" + node.class.to_s
      end

      @buffer
    end

    def parsed
      @parsed ||= Nokogiri::HTML.fragment(converted_erb)
    end

    def buffer
      Rufo::Formatter.format(@buffer.strip)
    rescue Rufo::SyntaxError
      @buffer.strip
    end

    def converted_erb
      ErbParser.transform_xml(html)
    rescue
      html
    end
  end
end