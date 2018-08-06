# -*- coding: utf-8 -*-
require 'spec_helper'
require 'rspec_api_documentation/dsl'

describe RspecApiDocumentation::Views::ApiBlueprintIndex do
  let(:reporter) { RSpec::Core::Reporter.new(RSpec::Core::Configuration.new) }
  let(:post_group) { RSpec::Core::ExampleGroup.resource("Posts") }
  let(:comment_group) { RSpec::Core::ExampleGroup.resource("Comments") }
  let(:rspec_example_post_get) do
    post_group.route "/posts/:id{?option=:option}", "Single Post" do
      parameter :id, "The id", required: true, type: "string", example: "1"
      parameter :option

      get("/posts/{id}") do
        example_request 'Gets a post' do
          explanation "Gets a post given an id"
        end

        example_request 'Returns an error' do
          explanation "You have to provide an id"
        end
      end
    end
  end

  let(:rspec_example_post_delete) do
    post_group.route "/posts/:id", "Single Post" do
      parameter :id, "The id", required: true, type: "string", example: "1"

      delete("/posts/:id") do
        example_request 'Deletes a post' do
          do_request
        end
      end
    end
  end

  let(:rspec_example_post_update) do
    post_group.route "/posts/:id", "Single Post" do
      parameter :id, "The id", required: true, type: "string", example: "1"
      attribute :name, "Order name 1", required: true
      attribute :name, "Order name 2", required: true

      put("/posts/:id") do
        example_request 'Updates a post' do
          do_request
        end
      end
    end
  end


  let(:rspec_example_posts) do
    post_group.route "/posts", "Posts Collection" do
      attribute :description, required: false

      get("/posts") do
        example_request 'Get all posts' do
        end
      end
    end
  end

  let(:rspec_example_comments) do
    comment_group.route "/comments", "Comments Collection" do
      get("/comments") do
        example_request 'Get all comments' do
        end
      end
    end
  end
  let(:index) do
    RspecApiDocumentation::Index.new.tap do |index|
      index.examples << RspecApiDocumentation::Example.new(rspec_example_post_get, config)
      index.examples << RspecApiDocumentation::Example.new(rspec_example_post_delete, config)
      index.examples << RspecApiDocumentation::Example.new(rspec_example_post_update, config)
      index.examples << RspecApiDocumentation::Example.new(rspec_example_posts, config)
      index.examples << RspecApiDocumentation::Example.new(rspec_example_comments, config)
    end
  end
  let(:config) { RspecApiDocumentation::Configuration.new }

  subject { described_class.new(index, config) }

  describe '#sections' do
    it 'returns sections grouped' do
      expect(subject.sections.count).to eq 2
      expect(subject.sections[0][:resource_name]).to eq "Comments"
      expect(subject.sections[1][:resource_name]).to eq "Posts"
    end

    describe "#routes" do
      let(:sections) { subject.sections }

      it "returns routes grouped" do
        comments_route = sections[0][:routes][0]
        posts_route = sections[1][:routes][0]
        post_route = sections[1][:routes][1]
        post_route_with_optionals = sections[1][:routes][2]

        comments_examples = comments_route[:http_methods].map { |http_method| http_method[:examples] }.flatten
        expect(comments_examples.size).to eq 1
        expect(comments_route[:route]).to eq "/comments"
        expect(comments_route[:route_name]).to eq "Comments Collection"
        expect(comments_route[:has_parameters?]).to eq false
        expect(comments_route[:parameters]).to eq []
        expect(comments_route[:has_attributes?]).to eq false
        expect(comments_route[:attributes]).to eq []

        post_examples = post_route[:http_methods].map { |http_method| http_method[:examples] }.flatten
        expect(post_examples.size).to eq 2
        expect(post_route[:route]).to eq "/posts/{id}"
        expect(post_route[:route_name]).to eq "Single Post"
        expect(post_route[:has_parameters?]).to eq true
        expect(post_route[:parameters]).to eq [{
          required: true,
          type: "string",
          example: "1",
          name: "id",
          description: "The id",
          properties_description: "required, string"
        }]
        expect(post_route[:has_attributes?]).to eq true
        expect(post_route[:attributes]).to eq [{
          required: true,
          name: "name",
          description: "Order name 1",
          properties_description: "required"
        }]

        post_w_optionals_examples = post_route_with_optionals[:http_methods].map { |http_method| http_method[:examples] }.flatten
        expect(post_w_optionals_examples.size).to eq 1
        expect(post_route_with_optionals[:route]).to eq "/posts/{id}{?option=:option}"
        expect(post_route_with_optionals[:route_name]).to eq "Single Post"
        expect(post_route_with_optionals[:has_parameters?]).to eq true
        expect(post_route_with_optionals[:parameters]).to eq [{
          required: true,
          type: "string",
          example: "1",
          name: "id",
          description: "The id",
          properties_description: "required, string"
        }, {
          name: "option",
          description: nil,
          properties_description: 'optional'
        }]
        expect(post_route_with_optionals[:has_attributes?]).to eq false
        expect(post_route_with_optionals[:attributes]).to eq []

        posts_examples = posts_route[:http_methods].map { |http_method| http_method[:examples] }.flatten
        expect(posts_examples.size).to eq 1
        expect(posts_route[:route]).to eq "/posts"
        expect(posts_route[:route_name]).to eq "Posts Collection"
        expect(posts_route[:has_parameters?]).to eq false
        expect(posts_route[:parameters]).to eq []
        expect(posts_route[:has_attributes?]).to eq true
        expect(posts_route[:attributes]).to eq [{
          required: false,
          name: "description",
          description: nil,
          properties_description: "optional"
        }]
      end
    end
  end
end
