load_paths = Dir["./vendor/bundle/ruby/2.5.0/bundler/gems/**/lib"]
$LOAD_PATH.unshift(*load_paths)

require 'sinatra'
require "sinatra/reloader" if development?

set :bind, '0.0.0.0'
set :port, '3002' if Sinatra::Application.environment == :development

also_reload File.join(File.dirname(__FILE__), 'gherkin_script_parser')
also_reload File.join(File.dirname(__FILE__), 'hiptest_publisher_xml_formatter')

require 'base64'
require 'builder'
require 'hiptest-publisher'
require 'logger'
require 'zip'

##
# Overwrite the hiptest-publisher method that tries to get the gem path
# because it does not work properly in a scenario where the gem is being loaded
# in a manner that is not a full gem within AWS Lambda
#
# Also, set the I18n load paths to match the proper path, since it seems to
# be set prior to us actively overwriting the below method.
def hiptest_publisher_path
  Gem.loaded_specs['hiptest-publisher'].full_gem_path
rescue
  Dir.glob("./vendor/bundle/ruby/2.5.0/bundler/gems/hiptest-publisher-*").first
rescue
  '.'
end

I18n.load_path << Dir["#{hiptest_publisher_path}/config/locales/*.yml"]
I18n.config.available_locales = :en

set :logger, Logger.new(STDOUT)

require_relative 'gherkin_script_parser'
require_relative 'hiptest_publisher_xml_formatter'

before do
  if request.body.size > 0
    request.body.rewind
    @params = Sinatra::IndifferentHash.new
    @params.merge!(JSON.parse(request.body.read))

    _parse_base64_encoded_param(:xml)
    _parse_base64_encoded_param(:script)
  end
end

##
# When the user already has a Hiptest XML file
# they POST to this path with the xml passed as
# part of the parameters
#
post '/parse_xml' do
  begin
    halt 500, 'XML cannot be blank' if @params[:xml].nil? || @params[:xml].strip.empty?

    create_and_return_results(@params[:xml], @params[:language] || 'ruby', @params[:framework] || 'rspec', @params[:skipActionwordSignature] || false)
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
    halt 500, 'Script cannot be blank' if @params[:script].nil? || @params[:script].strip.empty?

    # Take in the gherkin script and parse it out into a Hiptest Publisher XML format
    parsed_script = GherkinScriptParser.new(@params[:script])
    hiptest_xml = HiptestPublisherXMLFormatter.format(parsed_script)

    create_and_return_results(hiptest_xml, @params[:language] || 'ruby', @params[:framework] || 'rspec', @params[:skipActionwordSignature] || false)
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
def create_and_return_results(xml_data, language, framework, skip_actionwords_signature)
  xml_file = generate_xml_tempfile(xml_data)
  cache_dir = Dir.mktmpdir
  output_dir = Dir.mktmpdir

  run_hiptest_publisher(xml_file, output_dir, cache_dir, language, framework)
  zip = zip_hiptest_publisher_results(output_dir, skip_actionwords_signature)
  send_response(zip)
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
def run_hiptest_publisher(xml_file, output_dir, cache_dir, language, framework)
  options = ["--xml-file=#{xml_file.path}", "--output-directory=#{output_dir}", "--cache-dir=#{cache_dir}", "--language=#{language}", '--no-uids']
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
  response.headers['Content-Type'] = "application/octet-stream"
  attachment('result.zip')
  response.write(Base64.encode64(zip.string))
end

##
# With the passed in temp directory, get
# the list of all the files within (excluding
# the current and parent directory pointers)
# and zip them up.
#
def zip_hiptest_publisher_results(dir, skip_actionwords_signature)
  entries = Dir.entries(dir) - %w(. ..)

  Zip::OutputStream.write_buffer do |stream|
    entries.each do |file_path|
      unless skip_actionwords_signature && file_path.include?('actionwords_signature.yaml')
        stream.put_next_entry(file_path)
        stream.write IO.read("#{dir}/#{file_path}")
      end
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

#################################
## Private
#################################

def _parse_base64_encoded_param(param_sym)
  @params[param_sym] = Base64.decode64(@params[param_sym]) if @params[param_sym] && @params[:isBase64Encoded]
end