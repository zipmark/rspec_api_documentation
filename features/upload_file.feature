Feature: Uploading a file
  Background:
    Given a file named "app.rb" with:
      """
      require 'rack'

      class App
        def self.call(env)
          request = Rack::Request.new(env)
          [200, {}, [request.params["file"][:filename]]]
        end
      end
      """

  Scenario: Uploading a text file
    Given a file named "file.txt" with:
      """
      a file to upload
      """
    And   a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"
      require "rack/test"

      RspecApiDocumentation.configure do |config|
        config.app = App
      end

      resource "FooBars" do
        post "/foobar" do
          parameter :name, "Name of file"
          parameter :file, "File to upload"

          let(:name) { "my-new-file.txt" }
          let(:file) do
            Rack::Test::UploadedFile.new("file.txt", "text/plain")
          end

          example_request "Uploading a file" do
            response_body.should == "file.txt"
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0

  Scenario: Uploading an image file
    Given I move the sample image into the workspace
    And   a file named "app_spec.rb" with:
      """
      require "rspec_api_documentation"
      require "rspec_api_documentation/dsl"
      require "rack/test"

      RspecApiDocumentation.configure do |config|
        config.app = App
      end

      resource "FooBars" do
        post "/foobar" do
          parameter :name, "Name of file"
          parameter :file, "File to upload"

          let(:name) { "my-new-file.txt" }
          let(:file) do
            Rack::Test::UploadedFile.new("file.png", "image/png")
          end

          example_request "Uploading a file" do
            response_body.should == "file.png"
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./app.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0
    And   the generated documentation should be encoded correctly
