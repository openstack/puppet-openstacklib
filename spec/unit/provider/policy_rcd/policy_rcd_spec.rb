require 'puppet'
require 'spec_helper'
require 'puppet/provider/policy_rcd/policy_rcd'
require 'tempfile'

provider_class = Puppet::Type.type(:policy_rcd).provider(:policy_rcd)

describe provider_class do
  let(:attributes) do {
       :name     => 'service',
       :set_code => '101'
    }
  end

  let(:resource) do
    Puppet::Type::Policy_rcd.new(attributes)
  end

  let(:provider) do
    resource.provider
  end

  subject { provider }

  describe 'managing policy' do
    describe '#create' do
      it 'creates a policy when policy-rc.d doesnt exist' do
        file = mock('file')
        provider.stubs(:policy_rcd).returns(file)
        File.expects(:exist?).with(file).returns(false)
        content = "# THIS FILE MANAGED BY PUPPET\n#!/bin/bash\n[[ \"$1\" == \"service\" ]] && exit 101\n"
        provider.class.expects(:write_to_file).with(file, content)
        provider.create
      end

      it 'creates a policy when policy-rc.d exists' do
        file = mock('file')
        provider.stubs(:policy_rcd).returns(file)
        File.expects(:exist?).with(file).returns(true)
        content = "[[ \"$1\" == \"service\" ]] && exit 101\n"
        provider.class.expects(:write_to_file).with(file, content)
        provider.create
      end
    end

    describe '#destroy' do
      it 'destroy a policy' do
        file = mock('file')
        file_content = "# THIS FILE MANAGED BY PUPPET\n#!/bin/bash\n[[ \"$1\" == \"service\" ]] && exit 101\n"
        provider.stubs(:policy_rcd).returns(file)
        File.expects(:exist?).with(file).returns(true)
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        provider.class.expects(:write_to_file).with(file, ['# THIS FILE MANAGED BY PUPPET', '#!/bin/bash'], true)
        provider.destroy
      end
    end

    describe '#flush' do
      it 'update a policy' do
        file = mock('file')
        provider.stubs(:policy_rcd).returns(file)
        file_content = "# THIS FILE MANAGED BY PUPPET\n#!/bin/bash\n[[ \"$1\" == \"service\" ]] && exit 102\n"
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        provider.class.expects(:write_to_file).with(file, ["# THIS FILE MANAGED BY PUPPET", "#!/bin/bash", "[[ \"$1\" == \"service\" ]] && exit 101\n"], true)
        provider.flush
      end

      it 'dont update a policy' do
        file = mock('file')
        file_content = "# THIS FILE MANAGED BY PUPPET\n#!/bin/bash\n[[ \"$1\" == \"service\" ]] && exit 101\n"
        provider.stubs(:policy_rcd).returns(file)
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        provider.flush
      end
    end
  end
end
