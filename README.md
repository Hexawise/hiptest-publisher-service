# Hiptest Publisher as a Service

The goal of this project is to provide an easy to use interface for the [Hiptest Publisher](https://github.com/hiptest/hiptest-publisher) gem that can be used through a web API.

## Getting Started

This service makes use of Ruby and Sinatra to provide a light weight web app.

### Installing

You can get the application up and going by using Docker or by running `bundle install` and then `ruby app.rb`

## Running the tests

The tests are written with [RSpec](https://github.com/rspec/rspec) and can be run by calling `bundle exec rspec`

## Endpoints

There are currently 2 endpoints

* **/parse** - POST request that expects a gherkin script to be passed as the parameter `script`.  Will return a binary octet stream of resulting test framework zip file.
* **/parse_xml** - POST request that expects a Hiptest formatted XML to be passed as the parameter `xml`.  Will return a binary octet stream of resulting test framework zip file.

Both endpoints support *language* and *framework* parameters to specify the Hiptest Publisher language and framework to export as.  As of right now, Hiptest Publisher supports:

 - Ruby (rspec / minitest)
 - Cucumber Ruby
 - Python (unittest)
 - Java (JUnit / TestNg)
 - Robot Framework
 - Selenium IDE
 - Javascript (qUnit / Jasmine)

 Defaults to **ruby* and **rspec**.

## Authors

* **Eric Musgrove** - *Initial work* - [Hexawise](https://github.com/Hexawise)

## License

This project is licensed under the GNU v2 License - see the [LICENSE.md](LICENSE.md) file for details
