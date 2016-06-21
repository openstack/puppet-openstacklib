Puppet::Type.type(:policy_rcd).provide(:policy_rcd) do

  desc 'Provider for managing policy-rc.d for Ubuntu'

  mk_resource_methods

  def check_os
    Facter.value(:osfamily) == 'Debian'
  end

  def check_policy_rcd
    return File.exist? policy_rcd
  end

  def file_lines
    @file_lines ||= File.open(policy_rcd).readlines
  end

  def policy_rcd
    '/usr/sbin/policy-rc.d'
  end

  def service
    @resource[:service]
  end

  def set_code
    @resource[:set_code]
  end

  def self.write_to_file(file, content, truncate=false)
    File.truncate(file, 0) if truncate
    policy = File.open(file, 'a+')
    policy.puts(content)
    policy.close
    File.chmod(0744, file)
  end

  def exists?
    # we won't do anything if os family is not debian
    return true unless check_os
    if check_policy_rcd
      file_lines.each do |line|
        unless line =~ /"#{@resource[:service]}"/
          next
        end
        return true
      end
    end
    false
  end

  def create
    unless check_policy_rcd
      header = "#!/bin/bash\n# THIS FILE MANAGED BY PUPPET\n"
    else
      header = ""
    end
    content = "#{header}[[ \"$1\" == \"#{@resource[:service]}\" ]] && exit #{@resource[:set_code]}\n"
    self.class.write_to_file(policy_rcd, content)
  end

  def destroy
    if check_policy_rcd
      file_lines.delete_if { |l| l =~ /"#{@resource[:service]}"/ }
      self.class.write_to_file(policy_rcd, file_lines, true)
    end
  end

  def flush
    if @resource[:ensure] == :present and ! file_lines.nil?
      new_line = nil
      outdated_line = nil
      file_lines.each do |line|
        unless line =~ /"#{@resource[:service]}"/
          next
        end
        code = line.match(/exit\s(\d+)/)[1]
        if code != @resource[:set_code]
          new_line = "[[ \"$1\" == \"#{@resource[:service]}\" ]] && exit #{@resource[:set_code]}\n"
          outdated_line = line
        end
      end
      unless new_line.nil?
        file_lines.delete(outdated_line)
        file_lines.push(new_line)
        self.class.write_to_file(policy_rcd, file_lines, true)
      end
    end
  end
end
