class HiptestPublisherXMLFormatter
  def self.format(script)
    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct! :xml, encoding: 'UTF-8'
    xml.project format: '0.1' do |project|
      project.name script.feature[:name]&.strip
      project.bdd_mode true
      project.testPlan do |testPlan|
        testPlan.folder do |folder|
          folder.name script.feature[:name]&.strip
          folder.description script.feature[:description]&.strip

          folder.tags do |tags|
            script.feature[:tags].each do |scriptTag|
              tags.tag do |tag|
                tag.key scriptTag[:name]&.strip&.tr('@', '')
              end
            end
          end
        end
      end

      project.scenarios do |scenarios|
        script.scenarios.each do |script_scenario|
          scenarios.scenario do |scenario|
            scenario.name script_scenario[:name]&.strip

            setup_scenario_tags(scenario, script_scenario)
            setup_scenario_datatable_and_parameters(scenario, script_scenario)
            setup_scenario_steps(scenario, script_scenario)
          end
        end
      end

      setup_actionwords(project, script.scenarios)
    end

    xml.target!
  end

  #################################
  ## XML Setup
  #################################

  ##
  # Accepts the current XML builder for project and the list
  # of actionwords for the current script.  Then generates the
  # XML setup for the actionwords, in the format of:
  #
  # <actionwords>
  #   <actionword>
  #     <name> ... </name>
  #     <parameters>
  #       <parameter>
  #         <name> ... </name>
  #       </parameter>
  #       ...
  #     </parameters>
  #   <actionword>
  # </actionwords>
  #
  def self.setup_actionwords(project, script_scenarios)
    script_actionwords = get_actionwords(script_scenarios)
    project.actionwords do |actionwords|
      script_actionwords.each do |script_actionword, actionword_parameters|
        actionwords.actionword do |actionword|
          actionword.name script_actionword

          if actionword_parameters.any?
            actionword.parameters do |parameters|
              actionword_parameters.each do |actionword_parameter|
                parameters.parameter do |parameter|
                  parameter.name actionword_parameter
                end
              end
            end
          end
        end
      end
    end
  end

  ##
  # Accepts the current XML builder for scenario script for
  # the given scenario.  Then generates the XML setup for
  # the datatable and parameters for the scenario, in the format of:
  #
  # <datatable>
  #   <dataset>
  #     <arguments>
  #       <argument>
  #         <name> ... </name>
  #         <value>
  #           <stringliteral> ... </stringliteral>
  #         </value>
  #       </argument>
  #       ...
  #     </arguments>
  #   </dataset>
  # </datatable>
  #
  # <parameters>
  #   <parameter>
  #     <name> ... </name>
  #   </parameter>
  #   ...
  # </parameters>
  #
  # We also ensure that we're only acting on this if we have an examples table and the examples table has a tableBody
  def self.setup_scenario_datatable_and_parameters(scenario, script_scenario)
    return unless script_scenario[:type] == :ScenarioOutline && !script_scenario[:examples].nil? && !script_scenario[:examples][0][:tableBody].nil?

    headers = script_scenario[:examples][0][:tableHeader][:cells].map { |header| header[:value] }

    parameter_name_length = parameter_count_for_examples_table(script_scenario[:examples])
    scenario.datatable do |datatable|
      script_scenario[:examples][0][:tableBody].each do |example_row|
        datatable.dataset do |dataset|
          dataset.arguments do |arguments|
            example_row[:cells].each_with_index do |example_cell, index|
              arguments.argument do |argument|
                argument.name headers[index]
                argument.value do |value|
                  if is_number?(example_cell[:value])
                    value.numericliteral example_cell[:value]&.strip
                  else
                    value.stringliteral example_cell[:value]&.strip.gsub("\n", '\n')
                  end
                end
              end
            end
          end
        end
      end
    end

    scenario.parameters do |parameters|
      parameter_name_length.times do |index|
        parameters.parameter do |parameter|
          parameter.name headers[index]
        end
      end
    end
  end

  ##
  # Accepts the current XML builder for scenario, the current
  # script for the scenario, and the current actionwords for the script.
  # Then generates the XML setup for the steps for a scenario, in the format of:
  #
  # <steps>
  #   <call>
  #     <actionword> ... </actionword>
  #     <annotation> ... </annotation>
  #     <arguments>
  #       <argument>
  #         <name> ... </name>
  #         <value>
  #           -- IF CURRENT SCENARIO TYPE IS 'SCENARIO'  --
  #           <template>
  #             <stringliteral> ... </stringliteral>
  #           </template>
  #           -- IF CURRENT SCENARIO TYPE IS 'SCENARIOOUTLINE' --
  #           <var> ... </var>
  #         </value>
  #       </argument>
  #       ...
  #     </arguments>
  #
  def self.setup_scenario_steps(scenario, script_scenario)
    scenario.steps do |steps|
      script_scenario[:steps].each do |scenario_step|
        steps.call do |call|
          scenario_parameters = parameters_for_scenario_step_text(script_scenario[:type], scenario_step[:text])
          step_parameters = parameters_for_step_text(scenario_step[:text])

          call.actionword format_step_text_for_parameters(script_scenario[:type], scenario_step[:text], scenario_parameters)
          call.annotation scenario_step[:keyword].strip

          if step_parameters.any?
            call.arguments do |arguments|
              step_parameters.each_with_index do |step_parameter, index|
                arguments.argument do |argument|
                  argument.name script_scenario[:type] == :ScenarioOutline ? step_parameter : scenario_parameters[index]
                  argument.value do |value|
                    if script_scenario[:type] == :ScenarioOutline
                      value.var step_parameter&.tr('<>', '')&.strip&.gsub("\n", '\n')
                    else
                      value.template do |template|
                        template.stringliteral step_parameter.tr('<>', '')&.strip&.gsub("\n", '\n')
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  ##
  # Accepts the current XML builder for scenario and the current
  # script for the scenario, then generates the XML setup for
  # the tags for a scenario, in the format of:
  #
  # <tags>
  #   <tag>
  #     <key> ... </key>
  #   </tag>
  #   ...
  # </tags>
  #
  def self.setup_scenario_tags(scenario, script_scenario)
    return if script_scenario[:tags].empty?

    scenario.tags do |tags|
      script_scenario[:tags].each do |script_tag|
        tags.tag do |tag|
          tag.key script_tag[:name]&.strip&.tr('@', '')
        end
      end
    end
  end

  #################################
  ## Data Formatting
  #################################

  ##
  # Accepts the current scenarios and goes through
  # them to find all the steps that we can use to
  # generate actionwords for.
  def self.get_actionwords(scenarios)
    actionwords = {}
    scenarios.each do |scenario|
      scenario[:steps].each do |step|
        step_parameter_values = parameters_for_scenario_step_text(scenario[:type], step[:text])
        step_parameter_names = parameters_for_step_text(step[:text])

        actionwords[format_step_text_for_parameters(scenario[:type], step[:text], step_parameter_values)] ||= []
        actionwords[format_step_text_for_parameters(scenario[:type], step[:text], step_parameter_values)] += step_parameter_values
      end
    end

    actionwords = actionwords.each { |k,v| actionwords[k] = v.uniq }
    actionwords
  end

  ##
  # Accepts the scenario step text for our current step, then
  # grabs the parameters for it, and replaces each parameter such
  # that our step text will match a given actionword, depending on
  # if it is a scenario or scenario outline
  #
  # scenario:
  #
  # the account balance is <account_balance>
  # becomes
  # the account balance is "p1"
  #
  # scenario outline:
  #
  # the account balance is <account_balance>
  # becomes
  # the account balance is "<account_balance>"
  #
  # also takes into account potential scenarios where a parmeter is
  # surrounded by quotation marks in the script and replaces double quotations
  # with a single
  #
  # the account balance is "<account_balance>"
  # becomes
  # the account balance is ""<account_balance>""
  # becomes
  # the account balance is "<account_balance>"
  #
  def self.format_step_text_for_parameters(scenario_type, scenario_step_text, step_parameters)
    if scenario_type == :ScenarioOutline
      parameters_for_step_text(scenario_step_text).reduce(scenario_step_text) { |step_text, parameter| step_text.gsub(parameter, "\"#{parameter}\"").gsub("\"\"#{parameter}\"\"", "\"#{parameter}\"") }.strip
    else
      parameters_for_step_text(scenario_step_text).each_with_index.reduce(scenario_step_text) { |step_text, (parameter, index)| step_text.gsub(parameter, "\"#{step_parameters[index]}\"").gsub("\"\"#{step_parameters[index]}\"\"", "\"#{step_parameters[index]}\"") }.strip
    end
  end

  ##
  # Accepts a string and determines if it is actually a number
  #
  def self.is_number?(string)
    true if Float(string) rescue false
  end

  ##
  # Accepts the current examples table, grabs the header row cells and
  # returns the count, to be used in mapping out the parameters within
  # a Scenario Outline
  #
  def self.parameter_count_for_examples_table(script_scenario_examples)
    script_scenario_examples[0][:tableHeader][:cells].length
  end

  ##
  # Accepts the scenario step text for our current step and searches
  # for the parameters in the current step that are in the format of
  # <parameter_name>
  #
  def self.parameters_for_step_text(scenario_step_text)
    scenario_step_text.scan(/(<[^>]+>)/).flatten.compact
  end

  ##
  # Accepts the scenario type and scenario text, then calls the
  # #parameters_for_step_text to get the parameters that exist on a given
  # line of text for a step.  From there, if this is a scenario outline, we
  # return the parameter value itself, in the form of <parameter_value>.
  # If it is a scenario, then we return an indexed parameter, in the form
  # of <p#>, where # is the current index value.
  def self.parameters_for_scenario_step_text(scenario_type, scenario_step_text)
    parameters_for_step_text(scenario_step_text).each_with_index.map do |parameter, index|
      if scenario_type == :ScenarioOutline
        parameter
      else
        "<p#{index+1}>"
      end
    end
  end
end