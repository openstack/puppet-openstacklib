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


module Puppet
module Util
class OpenStackConfig
  class Section

    @@SETTING_REGEX = /^(\s*)([^#;\s]|[^#;\s].*?[^\s=])(\s*=[ \t]*)(.*)\s*$/
    @@COMMENTED_SETTING_REGEX = /^(\s*)[#;]+(\s*)(.*?[^\s=])(\s*=[ \t]*)(.*)\s*$/

    def initialize(name, lines=nil)
      @name = name
      @lines = lines.nil? ? [] : lines
      # parse lines
      @indentation = nil
      @settings = {}
      @lines.each do |line|
        if match = @@SETTING_REGEX.match(line)
          indent = match[1].length
          @indentation = [indent, @indentation || indent].min
          if @settings.include?(match[2])
            if not @settings[match[2]].kind_of?(Array)
              @settings[match[2]] = [@settings[match[2]]]
            end
            @settings[match[2]].push(match[4])
          else
            @settings[match[2]] = match[4]
          end
        end
      end
    end

    attr_reader :name, :indentation

    def settings
      Marshal.load(Marshal.dump(@settings))
    end

    def lines
      @lines.clone
    end

    def is_global?
      @name == ''
    end

    def is_new_section?
      @lines.empty?
    end

    def setting_names
      @settings.keys
    end

    def add_setting(setting_name, value)
      @settings[setting_name] = value
      add_lines(setting_name, value)
    end

    def update_setting(setting_name, value)
      old_value = @settings[setting_name]
      @settings[setting_name] = value
      if value.kind_of?(Array) or old_value.kind_of?(Array)
        # ---- update lines for multi setting ----
        old_value = old_value.kind_of?(Array) ? old_value : [old_value]
        new_value = value.kind_of?(Array) ? value : [value]
        if useless = old_value - new_value
          remove_lines(setting_name, useless)
        end
        if missing = new_value - old_value
          add_lines(setting_name, missing)
        end
      else
        # ---- update lines for single setting ----
        @lines.each_with_index do |line, index|
          if match = @@SETTING_REGEX.match(line)
            if (match[2] == setting_name)
              @lines[index] = "#{match[1]}#{match[2]}#{match[3]}#{value}\n"
            end
          end
        end
      end
    end

    def remove_setting(setting_name, value=nil)
      if value.nil? or @settings[setting_name] == value
        @settings.delete(setting_name)
      else
        value.each do |val|
          @settings[setting_name].delete(val)
        end
      end
      remove_lines(setting_name, value)
    end

    private
    def find_commented_setting(setting_name)
      @lines.each_with_index do |line, index|
        if match = @@COMMENTED_SETTING_REGEX.match(line)
          if match[3] == setting_name
            return index
          end
        end
      end
      nil
    end

    def find_last_setting(setting_name)
      result = nil
      @lines.each_with_index do |line, index|
        if match = @@SETTING_REGEX.match(line)
          if match[2] == setting_name
            result = index
          end
        end
      end
      result
    end

    def remove_lines(setting_name, value=nil)
      if value.kind_of?(Array)
        val_arr = value
      else
        val_arr = [value]
      end
      val_arr.each do |val|
        @lines.each_with_index do |line, index|
          if (match = @@SETTING_REGEX.match(line))
            if match[2] == setting_name
              if val.nil? or val_arr.include?(match[4])
                @lines.delete_at(index)
                break
              end
            end
          end
        end
      end
    end

    def add_lines(setting_name, value)
      indent_str = ' ' * (indentation || 0)
      if current = find_last_setting(setting_name)
        offset = current
      elsif comment = find_commented_setting(setting_name)
        offset = comment + 1
      else
        offset = @lines.length
      end
      if value.kind_of?(Array)
        value.each do |val|
          @lines.insert(offset, "#{indent_str}#{setting_name}=#{val}\n")
          offset += 1
        end
      else
        @lines.insert(offset, "#{indent_str}#{setting_name}=#{value}\n")
      end
    end

  end
end
end
end
