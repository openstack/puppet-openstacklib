
#
# Forked from https://github.com/puppetlabs/puppetlabs-inifile .
#

require 'spec_helper'
require 'puppet/util/openstackconfig'


describe Puppet::Util::OpenStackConfig do
  include PuppetlabsSpec::Files

  let(:subject) do
    Puppet::Util::OpenStackConfig.new("/my/config/path")
  end

  before :each do
    allow(Puppet::Util::OpenStackConfig).to receive(:readlines).and_return(sample_content)
  end

  context "when parsing a file" do
    let(:sample_content) {
      template = <<-EOS
# This is a comment
[section1]
; This is also a comment
foo=foovalue

bar = barvalue
baz =
[section2]

foo= foovalue2
baz=bazvalue
 ; commented = out setting
    #another comment
 ; yet another comment
 zot = multi word value
 xyzzy['thing1']['thing2']=xyzzyvalue
 l=git log

 [section3]
 multi_setting = value1
 multi_setting = value2
      EOS
      template.split("\n")
    }

    it "should parse the correct number of sections" do
      # there is always a "global" section, so our count should be 3.
      expect(subject.section_names.length).to eq(4)
    end

    it "should parse the correct section_names" do
      # there should always be a "global" section named "" at the beginning of the list
      expect(subject.section_names).to eq(["", "section1", "section2", "section3"])
    end

    it "should expose settings for sections" do
      expect(subject.get_settings("section1")).to eq({
        "bar" => "barvalue",
        "baz" => "",
        "foo" => "foovalue"
      })

      expect(subject.get_settings("section2")).to eq({
        "baz" => "bazvalue",
        "foo" => "foovalue2",
        "l" => "git log",
        "xyzzy['thing1']['thing2']" => "xyzzyvalue",
        "zot" => "multi word value"
      })

      expect(subject.get_settings("section3")).to eq({
        "multi_setting" => ["value1", "value2"]
      })
    end

  end

  context "when parsing a file whose first line is a section" do
    let(:sample_content) {
      template = <<-EOS
[section1]
; This is a comment
foo=foovalue
      EOS
      template.split("\n")
    }

    it "should parse the correct number of sections" do
      # there is always a "global" section, so our count should be 2.
      expect(subject.section_names.length).to eq(2)
    end

    it "should parse the correct section_names" do
      # there should always be a "global" section named "" at the beginning of the list
      expect(subject.section_names).to eq(["", "section1"])
    end

    it "should expose settings for sections" do
      expect(subject.get_value("section1", "foo")).to eq("foovalue")
    end

  end

  context "when parsing a file with a 'global' section" do
    let(:sample_content) {
      template = <<-EOS
foo = bar
[section1]
; This is a comment
foo=foovalue
      EOS
      template.split("\n")
    }

    it "should parse the correct number of sections" do
      # there is always a "global" section, so our count should be 2.
      expect(subject.section_names.length).to eq(2)
    end

    it "should parse the correct section_names" do
      # there should always be a "global" section named "" at the beginning of the list
      expect(subject.section_names).to eq(["", "section1"])
    end

    it "should expose settings for sections" do
      expect(subject.get_value("", "foo")).to eq("bar")
      expect(subject.get_value("section1", "foo")).to eq("foovalue")
    end
  end

  context "when updating a file with existing empty values" do
    let(:sample_content) {
      template = <<-EOS
[section1]
foo=
#bar=
#xyzzy['thing1']['thing2']='xyzzyvalue'
      EOS
      template.split("\n")
    }

    it "should properly update uncommented values" do
      expect(subject.get_value("section1", "far")).to eq(nil)
      subject.set_value("section1", "foo", "foovalue")
      expect(subject.get_value("section1", "foo")).to eq("foovalue")
    end

    it "should properly update commented values" do
      expect(subject.get_value("section1", "bar")).to eq(nil)
      subject.set_value("section1", "bar", "barvalue")
      expect(subject.get_value("section1", "bar")).to eq("barvalue")
      expect(subject.get_value("section1", "xyzzy['thing1']['thing2']")).to eq(nil)
      subject.set_value("section1", "xyzzy['thing1']['thing2']", "xyzzyvalue")
      expect(subject.get_value("section1", "xyzzy['thing1']['thing2']")).to eq("xyzzyvalue")
    end

    it "should properly add new empty values" do
      expect(subject.get_value("section1", "baz")).to eq(nil)
    end
  end

  context 'the file has quotation marks in its section names' do
    let(:sample_content) do
      template = <<-EOS
[branch "master"]
        remote = origin
        merge = refs/heads/master

[alias]
to-deploy = log --merges --grep='pull request' --format='%s (%cN)' origin/production..origin/master
[branch "production"]
        remote = origin
        merge = refs/heads/production
      EOS
      template.split("\n")
    end

    it 'should parse the sections' do
      expect(subject.section_names).to eq([
        '',
        'branch "master"',
        'alias',
        'branch "production"'
      ])
    end
  end

  context 'Samba INI file with dollars in section names' do
    let(:sample_content) do
      template = <<-EOS
      [global]
        workgroup = FELLOWSHIP
        ; ...
        idmap config * : backend = tdb

      [printers]
        comment = All Printers
        ; ...
        browseable = No

      [print$]
        comment = Printer Drivers
        path = /var/lib/samba/printers

      [Shares]
        path = /home/shares
        read only = No
        guest ok = Yes
      EOS
      template.split("\n")
    end

    it "should parse the correct section_names" do
      expect(subject.section_names).to eq([
        '',
        'global',
        'printers',
        'print$',
        'Shares'
      ])
    end
  end

  context 'section names with forward slashes in them' do
    let(:sample_content) do
      template = <<-EOS
[monitor:///var/log/*.log]
disabled = test_value
      EOS
      template.split("\n")
    end

    it "should parse the correct section_names" do
      expect(subject.section_names).to eq([
        '',
        'monitor:///var/log/*.log'
      ])
    end
  end

  context 'KDE Configuration with braces in setting names' do
    let(:sample_content) do
      template = <<-EOS
      [khotkeys]
_k_friendly_name=khotkeys
{5465e8c7-d608-4493-a48f-b99d99fdb508}=Print,none,PrintScreen
{d03619b6-9b3c-48cc-9d9c-a2aadb485550}=Search,none,Search
EOS
      template.split("\n")
    end

    it "should expose settings for sections" do
      expect(subject.get_value("khotkeys", "{5465e8c7-d608-4493-a48f-b99d99fdb508}")).to eq("Print,none,PrintScreen")
      expect(subject.get_value("khotkeys", "{d03619b6-9b3c-48cc-9d9c-a2aadb485550}")).to eq("Search,none,Search")
    end
  end

  context 'Configuration with colons in setting names' do
    let(:sample_content) do
      template = <<-EOS
      [Drive names]
A:=5.25" Floppy
B:=3.5" Floppy
C:=Winchester
EOS
      template.split("\n")
    end

    it "should expose settings for sections" do
      expect(subject.get_value("Drive names", "A:")).to eq('5.25" Floppy')
      expect(subject.get_value("Drive names", "B:")).to eq('3.5" Floppy')
      expect(subject.get_value("Drive names", "C:")).to eq('Winchester')
    end
  end

  context 'Configuration with spaces in setting names' do
    let(:sample_content) do
      template = <<-EOS
      [global]
        # log files split per-machine:
        log file = /var/log/samba/log.%m

        kerberos method = system keytab
        passdb backend = tdbsam
        security = ads
EOS
      template.split("\n")
    end

    it "should expose settings for sections" do
      expect(subject.get_value("global", "log file")).to eq('/var/log/samba/log.%m')
      expect(subject.get_value("global", "kerberos method")).to eq('system keytab')
      expect(subject.get_value("global", "passdb backend")).to eq('tdbsam')
      expect(subject.get_value("global", "security")).to eq('ads')
    end
  end


  context 'Multi settings' do
    let(:sample_content) do
      template = <<-EOS
      [test]
        # multi values
        test = value1
        test = value2
        test = value3
EOS
      template.split("\n")
    end

    it "should expose setting with array value" do
      expect(subject.get_value("test", "test")).to eq(['value1', 'value2', 'value3'])
    end

    it "should create setting with array value" do
      subject.set_value("test", "test2", ['valueA', 'valueB', 'valueC'])
      expect(subject.get_value("test", "test2")).to eq(['valueA', 'valueB', 'valueC'])
    end
  end
end
