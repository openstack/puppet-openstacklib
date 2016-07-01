require 'spec_helper_acceptance'

describe 'Defaults manifest' do
  context 'virtual_package' do
    it_behaves_like 'puppet_apply_success_from_example', 'virtual_packages'
  end
end
