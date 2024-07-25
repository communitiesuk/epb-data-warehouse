module XmlPresenter
  class Xsd < Presenter::Xsd
  private

    def read_xml(file_name, node_name, node_hash)
      doc = Nokogiri.XML(File.read(file_name))
      enums_hash = {}

      doc.xpath(node_name).each do |node|
        enums_hash.merge!(node.xpath(node_hash.keys[0].to_s).children.text => node.xpath(node_hash.values[0]).children.text)
      end

      enums_hash
    end
  end
end
