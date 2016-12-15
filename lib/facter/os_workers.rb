#
# We've found that using $::processorcount for workers/threads can lead to
# unexpected memory or process counts for people deploying on baremetal or
# if they have large number of cpus. This fact allows us to tweak the formula
# used to determine number of workers in a single place but use it across all
# modules.
#
# The value for os_workers is max between '(<# processors> / 4)' and '2' with
# a cap of 8.
#
# This fact can be overloaded by an external fact from /etc/factor/facts.d if
# a user would like to provide their own default value.
#
Facter.add(:os_workers_small) do
  has_weight 100
  setcode do
    processors = Facter.value('processorcount')
    [ [ (processors.to_i / 4), 2 ].max, 8 ].min
  end
end

#
# The value above for os_workers performs 3x worse in many cases compared to
# the prevuous default of $::processorcount.
#
# Based on performance data [1], the following calculation is within 1-2%.
#
# The value for os_workers is max between '(<# processors> / 2)' and '2' with
# a cap of 12.
#
# [1] http://elk.browbeatproject.org:80/goto/a23307fd511e314b975dedca6f65425d
#
Facter.add(:os_workers) do
  has_weight 100
  setcode do
    processors = Facter.value('processorcount')
    [ [ (processors.to_i / 2), 2 ].max, 12 ].min
  end
end

#
# For cases where services are not co-located together (ie monolithic).
#
Facter.add(:os_workers_large) do
  has_weight 100
  setcode do
    processors = Facter.value('processorcount')
    [ (processors.to_i / 2) ]
  end
end
