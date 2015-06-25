require 'spec_helper'
describe 'swarm' do

  context 'with defaults for all parameters' do
    it { should contain_class('swarm') }
  end
end
