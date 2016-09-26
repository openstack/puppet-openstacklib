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
Facter.add(:os_workers) do
  has_weight 100
  setcode do
    processors = Facter.value('processorcount')
    [ [ (processors.to_i / 4), 2 ].max, 8 ].min
  end
end
