# Hiptest Publisher as a Service

The goal of this project is to provide an easy to use interface for the [Hiptest Publisher](https://github.com/hiptest/hiptest-publisher) gem that can be used through a web API.

## Getting Started

This service makes use of Ruby and Sinatra to provide a light weight web app which is also compatible with AWS Lambda.

### Installing

You can get the application up and going by using Docker or by running `bundle install` and then `rackup app/config.ru`

## Running the tests

The tests are written with [RSpec](https://github.com/rspec/rspec) and can be run by calling `bundle exec rspec`

## Endpoints

There are currently 2 endpoints

- **/parse** - POST request that expects a gherkin script to be passed as the parameter `script`. Will return a binary octet stream of resulting test framework zip file.
- **/parse_xml** - POST request that expects a Hiptest formatted XML to be passed as the parameter `xml`. Will return a binary octet stream of resulting test framework zip file.

In the case of an error, a response with status code 500 will be returned, with the body containing the error message string.

Both endpoints support `language` and `framework` parameters to specify the Hiptest Publisher language and framework to export as. As of right now, Hiptest Publisher supports:

- Behat
- Behave
- CSharp (Nunit)
- Cucumber (Groovy, Java, Javascript, Ruby)
- Groovy (Spock)
- Java (Espresso / JUnit / TestNg)
- Javascript (Jasmine, Mocha, Protractor, qUnit)
- JBehave
- PHO (PHPUnit, UnitTest)
- Robot Framework
- Ruby (MiniTest, RSpec)
- Selenium IDE
- SpecFlow

Defaults to **ruby** and **rspec**.

Part of the export includes a file, `actionwords_signature.yaml`, which is utilized by the Hiptest service itself. If you want to exclude that, you can pass the `skipActionwordSignature` parameter. This defaults to **false**.

The final parameter accepted is `isBase64Encoded`, which tells the server if the content has been Base64 encoded and needs to be decoded prior to parsing it. This is generally encouraged to ensure that there are no potential parsing errors when POSTing your XML or Gherkin script. This parameter is optional.

## Lambda

This service was designed with the intent to work easily with the AWS Lambda service, and in such, installing it is fairly easy.

First off, you will need to ensure you have the [AWS SAM CLI installed](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html).

Then, create the deployment package (note: if you don't have a S3 bucket, you need to create one):

```console
$ sam package \
     --template-file template.yaml \
     --output-template-file packaged-template.yaml \
     --s3-bucket { your-bucket-name }
```

Finally, deploy out your application:

```console
sam deploy --template-file packaged-template.yaml \
     --stack-name { your-stack-name } \
     --capabilities CAPABILITY_IAM
```

From there, you can look within [Amazon API Gateway](https://console.aws.amazon.com/apigateway/home) to find your API and get the Invoke URL for a given stage.

## Authors

- **Eric Musgrove** - _Initial work_ - [Hexawise](https://github.com/Hexawise)

## License

This project is licensed under the GNU v2 License - see the [LICENSE.md](LICENSE.md) file for details
