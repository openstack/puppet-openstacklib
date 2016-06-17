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

  let(:header) do
    "#!/bin/bash\n# THIS FILE MANAGED BY PUPPET\n"
  end

  describe 'managing policy' do
    describe '#create' do
      it 'creates a policy when policy-rc.d doesnt exist' do
        file = mock('file')
        provider.stubs(:policy_rcd).returns(file)
        File.expects(:exist?).with(file).returns(false)
        content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
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
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
        provider.stubs(:policy_rcd).returns(file)
        File.expects(:exist?).with(file).returns(true)
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        provider.class.expects(:write_to_file).with(file, ['#!/bin/bash', '# THIS FILE MANAGED BY PUPPET'], true)
        provider.destroy
      end
    end

    describe '#flush' do
      it 'update a policy' do
        file = mock('file')
        provider.stubs(:policy_rcd).returns(file)
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 102\n"
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        provider.class.expects(:write_to_file).with(file, ['#!/bin/bash', "# THIS FILE MANAGED BY PUPPET", "[[ \"$1\" == \"service\" ]] && exit 101\n"], true)
        provider.flush
      end

      it 'dont update a policy' do
        file = mock('file')
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
        provider.stubs(:policy_rcd).returns(file)
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        provider.flush
      end
    end

    describe '#exists?' do
      it 'should exists on Debian family' do
        provider.stubs(:check_os).returns(true)
        file = mock('file')
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
        provider.stubs(:policy_rcd).returns(file)
        provider.stubs(:check_policy_rcd).returns(true)
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        expect(provider.exists?).to be_truthy
      end

      it 'should not exists on Debian family when file is present' do
        provider.stubs(:check_os).returns(true)
        file = mock('file')
        file_content = "#{header}[[ \"$1\" == \"new-service\" ]] && exit 101\n"
        provider.stubs(:policy_rcd).returns(file)
        provider.stubs(:check_policy_rcd).returns(true)
        provider.stubs(:file_lines).returns(file_content.split("\n"))
        expect(provider.exists?).to be_falsey
      end

      it 'should not exists on Debian family when file is not present' do
        provider.stubs(:check_os).returns(true)
        provider.stubs(:check_policy_rcd).returns(false)
        expect(provider.exists?).to be_falsey
      end

      it 'should exists on non-Debian family' do
        provider.stubs(:check_os).returns(false)
        expect(provider.exists?).to be_truthy
      end
    end

    describe 'write_to_file' do
      it 'should write to file' do
        file = mock
        policy = mock
        content = 'some_content'
        File.expects(:open).with(file, 'a+').returns(policy)
        policy.expects(:puts).with(content)
        policy.expects(:close)
        File.expects(:chmod).with(0744, file)
        provider.class.write_to_file(file, content)
      end

      it 'should truncate file' do
        file = mock
        policy = mock
        content = 'some_content'
        File.expects(:truncate).with(file, 0)
        File.expects(:open).with(file, 'a+').returns(policy)
        policy.expects(:puts).with(content)
        policy.expects(:close)
        File.expects(:chmod).with(0744, file)
        provider.class.write_to_file(file, content, true)
      end
    end
  end
end
