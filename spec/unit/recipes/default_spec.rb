#
# Cookbook Name:: mesos
# Spec:: default
#

require 'spec_helper'

describe 'mesos_v2::default' do
  context 'It should include recipe install' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '7.1.1503')
      runner.converge(described_recipe)
    end
    it 'includes mesos_v2::install recipe' do
      expect(chef_run).to include_recipe('mesos_v2::install')
    end
  end
end
