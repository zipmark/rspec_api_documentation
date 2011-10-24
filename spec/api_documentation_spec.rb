require 'spec_helper'

describe RspecApiDocumentation::ApiDocumentation do
  let(:configuration) { RspecApiDocumentation::Configuration.new }
  let(:documentation) { RspecApiDocumentation::ApiDocumentation.new(configuration) }

  subject { documentation }

  its(:configuration) { should equal(configuration) }

  describe "#clear_docs" do
    include FakeFS::SpecHelpers

    it "should rebuild the docs directory" do
      test_file = configuration.docs_dir.join("test")
      FileUtils.mkdir_p configuration.docs_dir
      FileUtils.touch test_file

      subject.clear_docs

      File.directory?(configuration.docs_dir).should be_true
      File.exists?(test_file).should be_false
    end

    it "should rebuild the public docs directory" do
      test_file = configuration.public_docs_dir.join("test")
      FileUtils.mkdir_p configuration.public_docs_dir
      FileUtils.touch test_file

      subject.clear_docs

      File.directory?(configuration.public_docs_dir).should be_true
      File.exists?(test_file).should be_false
    end
  end
end
