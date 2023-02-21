require "nokogiri"

module XmlPresenter
  class Parser
    def initialize(excludes: [], includes: [], bases: [], preferred_keys: {}, list_nodes: [], rootless_list_nodes: {}, specified_report: nil, ignored_attributes: [])
      @excludes = excludes
      @includes = includes
      @bases = bases
      @preferred_keys = preferred_keys
      @list_nodes = list_nodes
      @rootless_list_nodes = rootless_list_nodes
      @specified_report = specified_report
      @ignored_attributes = ignored_attributes
    end

    def parse(xml)
      sax_parser(xml).parse xml
      last_output
    end

    def root_node_option(xml)
      if @specified_report
        {
          index: find_index(xml),
          name: @specified_report[:root_node],
        }
      end
    end

    def sax_parser(xml)
      @assessment_document ||= AssessmentDocument.new excludes: @excludes,
                                                      includes: @includes,
                                                      bases: @bases,
                                                      preferred_keys: @preferred_keys,
                                                      list_nodes: @list_nodes,
                                                      rootless_list_nodes: @rootless_list_nodes,
                                                      root_node: root_node_option(xml),
                                                      ignored_attributes: @ignored_attributes
      @sax_parser ||= Nokogiri::XML::SAX::Parser.new @assessment_document
    end

  private

    def last_output
      @assessment_document.output
    end

    def find_index(xml)
      report_index = ReportIndex.new(**@specified_report)
      Nokogiri::XML::SAX::Parser.new(report_index).parse(xml)
      report_index.correct_index
    end
  end

  class ReportIndex < Nokogiri::XML::SAX::Document
    def initialize(root_node:, sub_node:, sub_node_value:)
      @root_node = root_node
      @sub_node = sub_node
      @sub_node_value = sub_node_value
      super()
    end

    def start_document
      @node_index = -1
    end

    def start_element_namespace(name, _attrs = nil, _prefix = nil, _uri = nil, _namespace = nil)
      if name == @root_node
        @node_index += 1
      end

      if name == @sub_node
        @in_subnode = true
      end
    end

    def end_element_namespace(name, _prefix = nil, _uri = nil)
      if name == @sub_node
        @in_subnode = false
      end
    end

    def characters(string)
      if @in_subnode == true && @sub_node_value == string.strip
        @correct_index = @node_index
      end
    end

    ###
    # Handle cdata_blocks containing +string+
    def cdata_block(string)
      characters string
    end

    attr_reader :correct_index
  end

  class AssessmentDocument < Nokogiri::XML::SAX::Document
    def initialize(excludes: [], includes: [], bases: [], preferred_keys: {}, list_nodes: [], rootless_list_nodes: {}, root_node: nil, ignored_attributes: [])
      @excludes = excludes
      @includes = includes
      @bases = bases
      @preferred_keys = preferred_keys
      @list_nodes = list_nodes
      @rootless_list_nodes = rootless_list_nodes
      @root_node = root_node
      @ignored_attributes = ignored_attributes
      super()
    end

    def start_document
      init!
      @output = {}
      @is_reading = @root_node.nil?
      @node_index = -1
    end

    def end_document
      init!
    end

    def start_element_namespace(name, attrs = nil, _prefix = nil, _uri = nil, _namespace = nil)
      if @root_node && name == @root_node[:name]
        @node_index += 1
        if @node_index == @root_node[:index]
          @is_reading = true
        end
      end
      return unless @is_reading

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
      @attrs = attrs.reject { |attr| @ignored_attributes.include?(attr.first) }
    end

    def end_element_namespace(name, _prefix = nil, _uri = nil)
      flush_value_buffer
      if @root_node && name == @root_node[:name]
        @is_reading = false
      end
      @output_position.pop unless is_base?(name)
      @output_position.pop if at_rootless_list_node_item?
      @source_position.pop
      @is_excluding = false if @excludes.include?(name)
      @is_including = false if @includes.include?(name)
    end

    def characters(string)
      if (@is_excluding && !@is_including) || !@is_reading
        return
      end

      if is_building_buffer?
        stripped = string
      else
        stripped = string.strip
        if stripped.empty?
          return
        end

        store_first_chunk string
      end

      value = try_as_number stripped

      if @attrs.length.positive?
        value = @attrs.to_h.merge({ "value" => value })
      end

      buffer_value value
    end

    ###
    # Handle cdata_blocks containing +string+
    def cdata_block(string)
      characters string
    end

    attr_reader :output

  private

    def init!
      @source_position = []
      @output_position = []
      @is_excluding = false
      @is_including = false
      @value_buffer = []
      @unstripped_first_value_chunk = nil
      @attrs = []
      @encountered = []
    end

    def as_key(name)
      if @preferred_keys.key?(name)
        return @preferred_keys[name]
      end

      name.downcase.tr("-", "_")
    end

    def buffer_value(value)
      if @value_buffer.length == 1 && !@unstripped_first_value_chunk.nil?
        @value_buffer[0] = @unstripped_first_value_chunk
      end
      @value_buffer << value
    end

    def flush_value_buffer
      @unstripped_first_value_chunk = nil
      case @value_buffer.length
      when 0
        return
      when 1
        set_value @value_buffer.first
      else
        set_value @value_buffer.join
      end

      @value_buffer.clear
    end

    def is_building_buffer?
      !@value_buffer.empty?
    end

    def store_first_chunk(chunk)
      @unstripped_first_value_chunk = chunk.lstrip if chunk.respond_to?(:lstrip)
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
      return if (@output_position.any? { |x| x.is_a? Integer } && !at_list_node_item?) || (@is_excluding && !@is_including)

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
