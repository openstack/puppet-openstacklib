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
        file = double('file')
        allow(provider).to receive(:policy_rcd).and_return(file)
        expect(File).to receive(:exist?).with(file).and_return(false)
        content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
        expect(provider.class).to receive(:write_to_file).with(file, content)
        provider.create
      end

      it 'creates a policy when policy-rc.d exists' do
        file = double('file')
        allow(provider).to receive(:policy_rcd).and_return(file)
        expect(File).to receive(:exist?).with(file).and_return(true)
        content = "[[ \"$1\" == \"service\" ]] && exit 101\n"
        expect(provider.class).to receive(:write_to_file).with(file, content)
        provider.create
      end
    end

    describe '#destroy' do
      it 'destroy a policy' do
        file = double('file')
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
        allow(provider).to receive(:policy_rcd).and_return(file)
        expect(File).to receive(:exist?).with(file).and_return(true)
        allow(provider).to receive(:file_lines).and_return(file_content.split("\n"))
        expect(provider.class).to receive(:write_to_file).with(file, ['#!/bin/bash', '# THIS FILE MANAGED BY PUPPET'], true)
        provider.destroy
      end
    end

    describe '#flush' do
      it 'update a policy' do
        file = double('file')
        allow(provider).to receive(:policy_rcd).and_return(file)
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 102\n"
        allow(provider).to receive(:file_lines).and_return(file_content.split("\n"))
        expect(provider.class).to receive(:write_to_file).with(file, ['#!/bin/bash', "# THIS FILE MANAGED BY PUPPET", "[[ \"$1\" == \"service\" ]] && exit 101\n"], true)
        provider.flush
      end

      it 'dont update a policy' do
        file = double('file')
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
        allow(provider).to receive(:policy_rcd).and_return(file)
        allow(provider).to receive(:file_lines).and_return(file_content.split("\n"))
        provider.flush
      end
    end

    describe '#exists?' do
      it 'should exists on Debian family' do
        allow(provider).to receive(:check_os).and_return(true)
        file = double('file')
        file_content = "#{header}[[ \"$1\" == \"service\" ]] && exit 101\n"
        allow(provider).to receive(:policy_rcd).and_return(file)
        allow(provider).to receive(:check_policy_rcd).and_return(true)
        allow(provider).to receive(:file_lines).and_return(file_content.split("\n"))
        expect(provider.exists?).to be_truthy
      end

      it 'should not exists on Debian family when file is present' do
        allow(provider).to receive(:check_os).and_return(true)
        file = double('file')
        file_content = "#{header}[[ \"$1\" == \"new-service\" ]] && exit 101\n"
        allow(provider).to receive(:policy_rcd).and_return(file)
        allow(provider).to receive(:check_policy_rcd).and_return(true)
        allow(provider).to receive(:file_lines).and_return(file_content.split("\n"))
        expect(provider.exists?).to be_falsey
      end

      it 'should not exists on Debian family when file is not present' do
        allow(provider).to receive(:check_os).and_return(true)
        allow(provider).to receive(:check_policy_rcd).and_return(false)
        expect(provider.exists?).to be_falsey
      end

      it 'should exists on non-Debian family' do
        allow(provider).to receive(:check_os).and_return(false)
        expect(provider.exists?).to be_truthy
      end
    end

    describe 'write_to_file' do
      it 'should write to file' do
        file = double
        policy = double
        content = 'some_content'
        expect(File).to receive(:open).with(file, 'a+').and_return(policy)
        expect(policy).to receive(:puts).with(content)
        expect(policy).to receive(:close)
        expect(File).to receive(:chmod).with(0744, file)
        provider.class.write_to_file(file, content)
      end

      it 'should truncate file' do
        file = double
        policy = double
        content = 'some_content'
        expect(File).to receive(:truncate).with(file, 0)
        expect(File).to receive(:open).with(file, 'a+').and_return(policy)
        expect(policy).to receive(:puts).with(content)
        expect(policy).to receive(:close)
        expect(File).to receive(:chmod).with(0744, file)
        provider.class.write_to_file(file, content, true)
      end
    end
  end
end
