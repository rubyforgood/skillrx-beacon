require "nokogiri"

class XmlParser
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def parse
    raise NotImplementedError, "Subclasses must implement #parse"
  end

  private

  def document
    @document ||= Nokogiri::XML(File.read(file_path))
  end
end
