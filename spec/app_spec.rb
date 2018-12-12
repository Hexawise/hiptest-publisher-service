require 'spec_helper'

describe "/parse" do
  it "should return 500 if the script is blank" do
    post "/parse"
    expect(last_response.body).to eq('Script cannot be blank')
    expect(last_response.status).to eq 500
  end

  it "should return 500 if the script cannot be parsed" do
    allow(GherkinScriptParser).to receive(:new).and_raise(StandardError)

    post "/parse", { 'script': 'Some Script Here' }
    expect(last_response.body).to start_with('There was an error parsing your script: ')
    expect(last_response.status).to eq 500
  end
end