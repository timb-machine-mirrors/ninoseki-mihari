# frozen_string_literal: true

require "yaml"

class Test
  include Mihari::Mixins::Rule
end

RSpec.describe Test do
  subject { described_class.new }

  describe "#initialize_rule_yaml" do
    it do
      files = Dry::Files.new(memory: true)
      filename = "/tmp/foo.yml"
      subject.initialize_rule_yaml(filename, files)

      data = YAML.safe_load(files.read(filename), symbolize_names: true)

      subject.validate_rule data

      expect(data.is_a?(Hash)).to eq(true)
    end
  end
end
