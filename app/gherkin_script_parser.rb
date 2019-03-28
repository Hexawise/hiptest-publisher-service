require 'gherkin/parser'

class GherkinScriptParser
  attr_accessor :name, :description, :scenarios

  ##
  # Accepts the Gherkin script, returning if the script
  # is nil or blank.  From there we pass it through the
  # Gherking::Parser, assigning it's name and the
  # scenarios to instance variables
  #
  def initialize(script)
    return if script.nil? || script&.strip&.empty?

    parser = Gherkin::Parser.new
    gherkin_document = parser.parse(script)

    @name = gherkin_document[:feature][:name].strip
    @description = gherkin_document[:feature][:description]&.strip
    @scenarios = gherkin_document[:feature][:children].map { |child| select_applicable_children(child) }.compact
  end

  ##
  # Accepts the current child of the feature from the
  # Gherkin script and returns it if the type is that
  # of a Scenario or Scenario Outline
  #
  def select_applicable_children(child)
    if child[:type] == :Scenario || child[:type] == :ScenarioOutline
      return child
    end
  end
end