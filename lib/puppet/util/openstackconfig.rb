#
# Author: Martin Magr <mmagr@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Forked from https://github.com/puppetlabs/puppetlabs-inifile .

require File.expand_path('../openstackconfig/section', __FILE__)


module Puppet
module Util
  class OpenStackConfig

    @@SECTION_REGEX = /^\s*\[(.*)\]\s*$/

    def initialize(path)
      @path = path
      @order = []
      @sections = {}
      parse_file
    end

    attr_reader :path

    def section_names
      @sections.keys
    end

    def get_settings(section_name)
      @sections[section_name].settings
    end

    def get_value(section_name, setting_name)
      if @sections.has_key?(section_name)
        @sections[section_name].settings[setting_name]
      end
    end

    def set_value(section_name, setting_name, value)
      unless @sections.has_key?(section_name)
        add_section(section_name)
      end
      if @sections[section_name].settings.has_key?(setting_name)
        @sections[section_name].update_setting(setting_name, value)
      else
        @sections[section_name].add_setting(setting_name, value)
      end
    end

    def remove_setting(section_name, setting_name, value=nil)
      @sections[section_name].remove_setting(setting_name, value)
    end

    def save
      File.open(@path, 'w') do |fh|
        @order.each do |section_name|
          if section_name.length > 0
            fh.puts("[#{section_name}]")
          end
          unless @sections[section_name].lines.empty?
            @sections[section_name].lines.each do |line|
              fh.puts(line)
            end
          end
        end
      end
    end

    private
    # This is mostly here because it makes testing easier
    # --we don't have to try to stub any methods on File.
    def self.readlines(path)
        # If this type is ever used with very large files, we should
        #  write this in a different way, using a temp
        #  file; for now assuming that this type is only used on
        #  small-ish config files that can fit into memory without
        #  too much trouble.
        File.file?(path) ? File.readlines(path) : []
    end

    def parse_file
      # We always create a "global" section at the beginning of the file,
      # for anything that appears before the first named section.
      lines = []
      current_section = ''
      OpenStackConfig.readlines(@path).each do |line|
        if match = @@SECTION_REGEX.match(line)
          add_section(current_section, lines)
          # start new section parsing
          lines = []
          current_section = match[1]
        else
          lines.push(line)
        end
      end
      add_section(current_section, lines)
    end

    def add_section(section_name, lines=nil)
      @order.push(section_name)
      @sections[section_name] = Section.new(section_name, lines)
    end

  end
end
end
