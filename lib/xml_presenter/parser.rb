module XmlPresenter
  class Parser
    def initialize(excludes: [], includes: [], bases: [], preferred_keys: {}, list_nodes: [], rootless_list_nodes: {})
      @excludes = excludes
      @includes = includes
      @bases = bases
      @preferred_keys = preferred_keys
      @list_nodes = list_nodes
      @rootless_list_nodes = rootless_list_nodes
    end

    def parse(xml)
      sax_parser.parse xml
      last_output
    end

    def sax_parser
      @assessment_document ||= AssessmentDocument.new excludes: @excludes,
                                                      includes: @includes,
                                                      bases: @bases,
                                                      preferred_keys: @preferred_keys,
                                                      list_nodes: @list_nodes,
                                                      rootless_list_nodes: @rootless_list_nodes
      @sax_parser ||= Nokogiri::XML::SAX::Parser.new @assessment_document
    end

  private

    def last_output
      @assessment_document.output
    end
  end

  class AssessmentDocument < Nokogiri::XML::SAX::Document
    def initialize(excludes: [], includes: [], bases: [], preferred_keys: {}, list_nodes: [], rootless_list_nodes: {})
      @excludes = excludes
      @includes = includes
      @bases = bases
      @preferred_keys = preferred_keys
      @list_nodes = list_nodes
      @rootless_list_nodes = rootless_list_nodes
      super()
    end

    def start_document
      init!
      @output = {}
    end

    def end_document
      init!
    end

    def start_element_namespace(name, attrs = nil, _prefix = nil, _uri = nil, _namespace = nil)
      @source_position << name
      @output_position << root_key_for_list if at_rootless_list_node_item?
      @output_position << as_key(name) unless is_base?(name)
      @is_excluding = true if @excludes.include?(name)
      @is_including = true if @includes.include?(name)
      super
      if encountered_position? || at_list_node_item?
        set_up_list
      end
      write_encounter
    end

    def start_element(_name, attrs = nil)
      @attrs = attrs
    end

    def end_element_namespace(name, _prefix = nil, _uri = nil)
      @output_position.pop unless is_base?(name)
      @output_position.pop if at_rootless_list_node_item?
      @source_position.pop
      @is_excluding = false if @excludes.include?(name)
      @is_including = false if @includes.include?(name)
    end

    def characters(string)
      if @is_excluding && !@is_including
        return
      end

      stripped = string.strip
      if stripped.length.zero?
        return
      end

      value = try_as_number stripped

      if @attrs.length.positive?
        value = @attrs.to_h.merge({ "value" => value })
      end

      set_value value
    end

    attr_reader :output

  private

    def init!
      @source_position = []
      @output_position = []
      @is_excluding = false
      @is_including = false
      @attrs = []
      @encountered = []
    end

    def as_key(name)
      if @preferred_keys.key?(name)
        return @preferred_keys[name]
      end

      name.downcase.tr("-", "_")
    end

    def set_value(value)
      set_value_with_keys(value, @output_position)
    end

    def set_value_with_keys(value, keys)
      prepare_hash keys
      *key, last = keys

      key.inject(@output, :fetch)[last] = value
    end

    def value_at(keys)
      keys.inject(@output, :fetch)
    rescue IndexError
      nil
    end

    def prepare_hash(keys)
      cursor = @output
      keys[..-2].each do |key|
        cursor[key] = {} unless cursor[key] && cursor[key] != ""
        cursor = cursor[key]
      end
    end

    def is_base?(name)
      @bases.concat(@excludes).include?(name) || name == @source_position[0]
    end

    def is_numeric?(string)
      true if Float(string)
    rescue StandardError
      false
    end

    def is_bool?(string)
      string == true || string == false || string =~ (/(true|false)$/i) ? true : false
    end

    def try_as_number(string)
      return string if is_bool?(string)
      return string unless is_numeric?(string)

      if string.include?(".")
        string.to_f
      else
        string.to_i
      end
    end

    def write_encounter
      @encountered << source_position_string
    end

    def encountered_position?
      @encountered.include? source_position_string
    end

    def source_position_string
      @source_position.join(">")
    end

    def set_up_list
      return if @output_position.any? { |x| x.is_a? Integer } && !at_list_node_item?

      candidate_list = value_at @output_position[..-2]

      case candidate_list
      when Array
        list_index = candidate_list.length
      when nil
        set_value_with_keys([], @output_position[..-2])
        list_index = 0
      else
        set_value_with_keys([candidate_list.values[0]], @output_position[..-2])
        list_index = 1
      end

      @output_position[-1] = list_index
    end

    def at_list_node_item?
      @list_nodes.include?(@source_position[-2]) || at_rootless_list_node_item?
    end

    def at_rootless_list_node_item?
      return unless @rootless_list_nodes.key?(@source_position[-1])

      case value = @rootless_list_nodes[@source_position[-1]]
      when String
        true
      else
        value[:parents].all? { |val| @source_position.include? val }
      end
    end

    def root_key_for_list
      case value = @rootless_list_nodes[@source_position[-1]]
      when String
        value
      else
        value[:key]
      end
    end
  end
end
