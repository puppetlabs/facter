# raid.rb
# Additional Facts about the machine's RAID-Controller
#
# Author: Lars Fronius (lars@jimdo.com)
#

if Facter.value(:kernel) == "Linux"
    raidcontroller_num = -1
    raidcontroller_list = []
    Facter::Util::Resolution.exec('lspci').each do |l|
        if l =~ /^\d{2}:\d{2}.\d{1} RAID bus controller: (.*)$/
            raidcontroller_num += 1
            raidcontroller_list[raidcontroller_num] = $1 unless raidcontroller_num == -1
        end
    end

    Facter.add("RAIDControllerCount") do
        confine :kernel => :linux
        setcode do
            if raidcontroller_list.length != 0
                raidcontroller_list.length.to_s
            end
        end
    end

    raidcontroller_list.each_with_index do |desc, i|
        Facter.add("RAIDController#{i}") do
            confine :kernel => :linux
            setcode do
                desc
            end
        end
    end
end
