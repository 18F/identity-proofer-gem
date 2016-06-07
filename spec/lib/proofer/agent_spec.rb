require 'spec_helper'

describe Proofer::Agent do
  describe '#new' do
    it 'initializes with config' do
      agent = Proofer::Agent.new vendor: :mock
      expect(agent).to be_a Proofer::Agent
    end
  end

  describe '#vendor' do
    it 'reports the current acting vendor' do
      agent = Proofer::Agent.new vendor: :mock
      expect(agent.vendor).to eq :mock
    end
  end
end
