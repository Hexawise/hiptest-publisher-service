class HiptestPublisherXMLFormatter
  def self.format(script)
    script_actionwords = get_actionwords(script.scenarios)

    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct! :xml, encoding: 'UTF-8'
    xml.project format: '0.1' do |project|
      project.name script.name
      project.scenarios do |scenarios|
        script.scenarios.each do |script_scenario|
          scenarios.scenario do |scenario|
            scenario.name script_scenario[:name].strip

            setup_scenario_tags(scenario, script_scenario)
            setup_scenario_datatable_and_parameters(scenario, script_scenario)
            setup_scenario_steps(scenario, script_scenario, script_actionwords)
          end
        end
      end

      setup_actionwords(project, script_actionwords)
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
  def self.setup_actionwords(project, script_actionwords)
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
                  value.stringliteral example_cell[:value]
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
  def self.setup_scenario_steps(scenario, script_scenario, script_actionwords)
    scenario.steps do |steps|
      script_scenario[:steps].each do |scenario_step|
        steps.call do |call|
          scenario_parameters = parameters_for_step_text(scenario_step[:text])
          step_action = format_step_text_for_parameters(scenario_step[:text])
          step_parameters = script_actionwords[step_action]

          call.actionword step_action
          call.annotation scenario_step[:keyword].strip

          if step_parameters.any?
            call.arguments do |arguments|
              step_parameters.each_with_index do |step_parameter, index|
                arguments.argument do |argument|
                  argument.name step_parameter # scenario_parameter
                  argument.value do |value|
                    if script_scenario[:type] == :Scenario
                      value.template do |template|
                        template.stringliteral scenario_parameters[index]
                      end
                    else
                      value.var step_parameter
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
    return if script_scenario[:tags].nil?

    scenario.tags do |tags|
      script_scenario[:tags].each do |script_tag|
        tags.tag do |tag|
          tag.key script_tag[:name]
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
    parameter_index = 0
    scenarios.each do |scenario|
      scenario[:steps].each do |step|
        step_parameters = parameters_for_step_text(step[:text]).map do |parameter|
          if scenario[:type] == :ScenarioOutline
            parameter
          else
            parameter_index += 1
            "p#{parameter_index}"
          end
        end

        actionwords[format_step_text_for_parameters(step[:text])] ||= step_parameters
      end
    end

    actionwords
  end

  ##
  # Accepts the scenario step text for our current step, then
  # grabs the parameters for it, and removes each parameter such
  # that our step text will match a given actionword.
  #
  # the account balance is <account_balance>
  # becomes
  # the account balance is
  #
  def self.format_step_text_for_parameters(scenario_step_text)
    parameters_for_step_text(scenario_step_text).reduce(scenario_step_text) { |step_text, parameter| step_text.gsub(" <#{parameter}>", '') }.strip
  end

  ##
  # Accepts the scenario step text for our current step and searches
  # for the parameters in the current step that are in the format of
  # <parameter_name>
  #
  def self.parameters_for_step_text(scenario_step_text)
    scenario_step_text.scan(/<([^>]+)>/).flatten
  end

  ##
  # Accepts the current examples table, grabs the header row cells and
  # returns the count, to be used in mapping out the parameters within
  # a Scenario Outline
  #
  def self.parameter_count_for_examples_table(script_scenario_examples)
    script_scenario_examples[0][:tableHeader][:cells].length
  end
end