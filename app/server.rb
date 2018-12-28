require 'sinatra'
require "sinatra/reloader" if development?
also_reload '../lib/*.rb'

require 'builder'
require 'hiptest-publisher'
require 'logger'
require 'zip'

require '../lib/gherkin_script_parser'
require '../lib/hiptest_publisher_xml_formatter'

set :bind, '0.0.0.0'
set :logger, Logger.new(STDOUT)

##
# When the user already has a Hiptest XML file
# they POST to this path with the xml passed as
# part of the parameters
#
post '/parse_xml' do
  begin
    halt 500, 'XML cannot be blank' if params[:xml].nil? || params[:xml].strip.empty?

    create_and_return_results(params[:xml], params[:language] || 'ruby', params[:framework] || 'rspec')
  rescue StandardError => exception
    handle_exception(exception)
  end
end

##
# When the user does not have Hiptest XML, they
# POST to this path with the Gherkin script passed
# as part of the parameters.  We will take that script,
# parse it out, create a Hiptest XML file, and then from
# there we will run that through Hiptest Publisher and
# return the resulting files
#
post '/parse' do
  begin
    halt 500, 'Script cannot be blank' if params[:script].nil? || params[:script].strip.empty?

    # Take in the gherkin script and parse it out into a Hiptest Publisher XML format
    parsed_script = GherkinScriptParser.new(params[:script])
    hiptest_xml = HiptestPublisherXMLFormatter.format(parsed_script)

    create_and_return_results(hiptest_xml, params[:language] || 'ruby', params[:framework] || 'rspec')
  rescue StandardError => exception
    handle_exception(exception)
  end
end

#################################
## Control Logic
#################################

##
# Takes in the XML data and generates a tempfile
# for it, creates a temp directory, then
# runs our hiptest publisher, zips the output
# and sends the response back.
#
def create_and_return_results(xml_data, language, framework)
  xml_file = generate_xml_tempfile(xml_data)
  Dir.mktmpdir do |dir|
    run_hiptest_publisher(xml_file, dir, language, framework)
    zip = zip_hiptest_publisher_results(dir)
    send_response(zip)
  end
end

##
# Takes in the xml data, generates a tempfile
# with that data, and returns the tempfile pointer.
#
def generate_xml_tempfile(xml_data)
  file = Tempfile.new('publisher')
  file.write(xml_data)
  file.close

  file
end

##
# Run our hiptest publisher with the xml file and output
# directory.
#
def run_hiptest_publisher(xml_file, dir, language, framework)
  options = ["--xml-file=#{xml_file.path}", "--output-directory=#{dir}", "--language=#{language}"]
  options << "--framework=#{framework}" unless framework.empty?
  publisher = Hiptest::Publisher.new(options)
  publisher.run
end

##
# Given the passed in zip file, generate a response
# with the zip as the attachment and the body as the
# binary data from the zip file.
#
def send_response(zip)
  response.headers['content_type'] = "application/octet-stream"
  attachment('result.zip')
  response.write(zip.string)
end

##
# With the passed in temp directory, get
# the list of all the files within (excluding
# the current and parent directory pointers)
# and zip them up.
#
def zip_hiptest_publisher_results(dir)
  entries = Dir.entries(dir) - %w(. ..)

  Zip::OutputStream.write_buffer do |stream|
    entries.each do |file_path|
      stream.put_next_entry(file_path)
      stream.write IO.read("#{dir}/#{file_path}")
    end
  end
end

#################################
## Error Handling
#################################

def handle_exception(exception)
  logger.error exception.message
  logger.error exception.backtrace.join("\n")
  halt 500, "There was an error parsing your script: #{exception.message}"
end