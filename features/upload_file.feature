Feature: Uploading a file
  Background:
    Given a file named "nonestedparam.rb" with:
      """
      require 'rack'

      class App
        def self.call(env)
          request = Rack::Request.new(env)
          [200, {}, [request.params["file"][:filename]]]
        end
      end
      """
    Given a file named "nestedparam.rb" with:
      """
      require 'rack'

      class App
        def self.call(env)
          request = Rack::Request.new(env)
          [200, {}, [request.params["post"]["file"][:filename]]]
        end
      end
      """
    Given a file named "nested_param_in_array.rb" with:
      """
      require 'rack'

      class App
        def self.call(env)
          request = Rack::Request.new(env)
          [200, {}, [request.params["post"]["files"][0][:filename]]]
        end
      end
      """

  Scenario: Uploading a text file with nested parameters
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
          parameter :post, "Post parameter"

          let(:post) do
            {
              id: 1,
              file: Rack::Test::UploadedFile.new("file.txt", "text/plain")
            }
          end

          example_request "Uploading a file" do
            expect(response_body).to eq("file.txt")
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./nestedparam.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0

  Scenario: Uploading a text file, no nested parameters
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
          parameter :file, "File to upload"

          let(:file) do
            Rack::Test::UploadedFile.new("file.txt", "text/plain")
          end

          example_request "Uploading a file" do
            expect(response_body).to eq("file.txt")
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./nonestedparam.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0

  Scenario: Uploading an image file, no nested parameters
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
          parameter :file, "File to upload"

          let(:file) do
            Rack::Test::UploadedFile.new("file.png", "image/png")
          end

          example_request "Uploading a file" do
            expect(response_body).to eq("file.png")
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./nonestedparam.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0
    And   the generated documentation should be encoded correctly

  Scenario: Uploading an image file, no nested parameters
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
          parameter :post, "Post parameter"

          let(:post) do
            {
              id: 10,
              file: Rack::Test::UploadedFile.new("file.png", "image/png")
            }
          end

          example_request "Uploading a file" do
            expect(response_body).to eq("file.png")
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./nestedparam.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0
    And   the generated documentation should be encoded correctly

  Scenario: Uploading an image file in params array
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
          parameter :post, "Post parameter"

          let(:post) do
            {
              id: 10,
              files: [ Rack::Test::UploadedFile.new("file.png", "image/png") ]
            }
          end

          example_request "Uploading a file" do
            expect(response_body).to eq("file.png")
          end
        end
      end
      """

    When  I run `rspec app_spec.rb --require ./nested_param_in_array.rb --format RspecApiDocumentation::ApiFormatter`

    Then  the output should contain "1 example, 0 failures"
    And   the exit status should be 0
    And   the generated documentation should be encoded correctly