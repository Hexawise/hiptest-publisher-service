# HipTest Publisher as a Service

The goal of this project is to provide an easy-to-use, serverless API for [HipTest Publisher](https://github.com/hiptest/hiptest-publisher) gem.

## Getting Started

This service makes use of [Ruby](https://www.ruby-lang.org/en/) and [Sinatra](http://sinatrarb.com/) to provide a light-weight web API which can be hosted anywhere, but is also compatible with [AWS Lambda](https://aws.amazon.com/lambda/) for serverless usage.

### Installing

You can get the API up and going locally by using [Docker](https://www.docker.com/) or by running `bundle install` and then `rackup app/config.ru`

## Running the tests

The tests are written with [RSpec](https://github.com/rspec/rspec) and can be run by calling `bundle exec rspec`

## API Endpoints

There are currently 2 API endpoints:

- **/parse** - POST request that expects a gherkin script to be passed as the parameter `script`. Will return a binary octet stream of resulting test framework zip file.
- **/parse_xml** - POST request that expects a Hiptest formatted XML to be passed as the parameter `xml`. Will return a binary octet stream of resulting test framework zip file.

In the case of an error, a response with status code `500` will be returned, with the body containing the error message string.

Both endpoints support `language` and `framework` parameters to specify the HipTest Publisher language and framework to export as. As of right now, Hiptest Publisher supports:

- Behat
- Behave
- CSharp (Nunit)
- Cucumber (Groovy, Java, Javascript, Ruby, TypeScript)
- Groovy (Spock)
- Java (Espresso / JUnit / TestNg)
- Javascript (Jasmine, Mocha, Protractor, qUnit)
- JBehave
- PHP (PHPUnit, UnitTest)
- Robot Framework
- Ruby (MiniTest, RSpec)
- Selenium IDE
- SpecFlow

Defaults to **ruby** and **rspec**.

Part of the export includes a file, `actionwords_signature.yaml`, which is utilized by the Hiptest service itself. If you want to exclude that, you can pass the `skipActionwordSignature` parameter. This defaults to **false**.

The final parameter accepted is `isBase64Encoded`, which tells the server if the content has been Base64 encoded and needs to be decoded prior to parsing it. This is generally encouraged to ensure that there are no potential parsing errors when POSTing your XML or Gherkin script. This parameter is optional.

## Lambda

This service was designed with the intent to work easily with AWS Lambda so installing it there is easy.

First, ensure you have the [AWS SAM CLI installed](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html).

Then, create the deployment package (note: if you don't have a S3 bucket, you need to create one):

```console
$ sam package \
     --template-file template.yaml \
     --output-template-file packaged-template.yaml \
     --s3-bucket { your-bucket-name }
```

Finally, deploy it:

```console
sam deploy --template-file packaged-template.yaml \
     --stack-name { your-stack-name } \
     --capabilities CAPABILITY_IAM
```

From there, you can look within the [Amazon API Gateway](https://console.aws.amazon.com/apigateway/home) to find your API and get the `Invoke URL` for a given stage.

## Authors

- **Eric Musgrove** - _Initial work_ - [Hexawise](https://github.com/Hexawise)
- **Sean Johnson** - _Editing_ - [Hexawise](https://github.com/Hexawise)

Of course, this service depends on the wonderful [HipTest Publisher gem](https://github.com/hiptest/hiptest-publisher) by HipTest, and the language/framework bindings from HipTest and the entire community.

## License

This project is licensed under the GNU v2 License - see the [LICENSE.md](LICENSE.md) file for details
