require 'facter/util/file_read'
require 'facter/util/operatingsystem'
require 'facter/operatingsystem/base'

module Facter
  module Operatingsystem
    class Linux < Base
      def get_operatingsystem
        if Facter.value(:kernel) == "GNU/kFreeBSD"
          "GNU/kFreeBSD"
        elsif lsbdistid = get_lsbdistid
          if lsbdistid == "Ubuntu"
            @operatingsystem ||= "Ubuntu"
          elsif lsbdistid == "LinuxMint"
            @operatingsystem ||= "LinuxMint"
          else
            @operatingsystem ||= get_operatingsystem_with_release_files
          end
        else
          @operatingsystem ||= get_operatingsystem_with_release_files
        end
      end

      def get_osfamily
        case get_operatingsystem
        when "RedHat", "Fedora", "CentOS", "Scientific", "SLC", "Ascendos", "CloudLinux", "PSBM", "OracleLinux", "OVS", "OEL", "Amazon", "XenServer"
          "RedHat"
        when "LinuxMint", "Ubuntu", "Debian"
          "Debian"
        when "SLES", "SLED", "OpenSuSE", "SuSE"
          "Suse"
        when "Gentoo"
          "Gentoo"
        when "Archlinux", "Manjarolinux"
          "Archlinux"
        when "Mageia", "Mandriva", "Mandrake"
          "Mandrake"
        else
          Facter.value("kernel")
        end
      end

      def get_operatingsystemrelease
        case get_operatingsystem
        when "Alpine"
          get_alpine_release_with_release_file
        when "Amazon"
          get_amazon_release_with_lsb
        when "AristaEOS"
          get_arista_release_with_release_file
        when "BlueWhite64"
          get_bluewhite_release_with_release_file
        when "CentOS", "RedHat", "Scientific", "SLC", "Ascendos", "CloudLinux", "PSBM",
             "XenServer", "Fedora", "MeeGo", "OracleLinux", "OEL", "oel", "OVS", "ovs"
          get_redhatish_release_with_release_file
        when "Debian"
          get_debian_release_with_release_file
        when "LinuxMint"
          get_linux_mint_release_with_release_file
        when "Mageia"
          get_mageia_release_with_release_file
        when "OpenWrt"
          get_openwrt_release_with_release_file
        when "Slackware"
          get_slackware_release_with_release_file
        when "Slamd64"
          get_slamd64_release_with_release_file
       when "SLES", "SLED", "OpenSuSE"
          get_suse_release_with_release_file
        when "Ubuntu"
          get_ubuntu_release_with_release_file
        when "VMwareESX"
          get_vmwareESX_release_with_release_file
        else
          Facter.value(:kernelrelease)
        end
      end

      def get_operatingsystemmajorrelease
        if operatingsystemrelease = get_operatingsystemrelease
          if get_operatingsystem == "Ubuntu"
            if (releasemajor = operatingsystemrelease.split("."))
              if releasemajor.length >= 2
                "#{releasemajor[0]}.#{releasemajor[1]}"
              else
                releasemajor[0]
              end
            end
          else
            if (releasemajor = operatingsystemrelease.split(".")[0])
              releasemajor
            end
          end
        end
      end

      def get_operatingsystemminorrelease
        if operatingsystemrelease = get_operatingsystemrelease
          if get_operatingsystem == "Ubuntu"
            if (releaseminor = operatingsystemrelease.split(".")[2])
              releaseminor
            end
          else
            if (releaseminor = operatingsystemrelease.split(".")[1])
              if releaseminor.include? "-"
                releaseminor.split("-")[0]
              else
                releaseminor
              end
            end
          end
        end
      end

      def has_lsb?
        true
      end

      def get_lsbdistcodename
        if (lsb_data = collect_lsb_information)
          lsb_data["Codename"]
        end
      end

      def get_lsbdistid
        if (lsb_data = collect_lsb_information)
          lsb_data["Distributor ID"]
        end
      end

      def get_lsbdistdescription
        if (lsb_data = collect_lsb_information)
          lsb_data["Description"].sub(/^"(.*)"$/,'\1')
        end
      end

      def get_lsbrelease
        if (lsb_data = collect_lsb_information)
          lsb_data["LSB Version"]
        end
      end

      def get_lsbdistrelease
        if (lsb_data = collect_lsb_information)
          lsb_data["Release"]
        end
      end

      def get_lsbmajdistrelease
        lsbdistrelease = get_lsbdistrelease
        if get_operatingsystem == "Ubuntu"
          if (lsbreleasemajor = lsbdistrelease.split("."))
            if lsbreleasemajor.length >= 2
              result = "#{lsbreleasemajor[0]}.#{lsbreleasemajor[1]}"
            else
              result = lsbreleasemajor
            end
          end
        else
          if /(\d*)\./i =~ lsbdistrelease
            result = $1
          else
            result = lsbdistrelease
          end
        end
        result
      end

      def get_lsbminordistrelease
        lsbdistrelease = get_lsbdistrelease
        if get_operatingsystem == "Ubuntu"
          mdata = /(\d+).(\d+).(\d+)/i.match(lsbdistrelease)
          if mdata == nil
            result = nil
          else
            result = mdata[3]
          end
        else
          mdata = /(\d+).(\d+)/i.match(lsbdistrelease)
          if mdata == nil
            result = nil
          else
            result = mdata[2]
          end
        end
        result
      end

      def get_lsb_facts_hash
        lsb_hash = {}
        if lsbdistcodename = get_lsbdistcodename
          lsb_hash["distcodename"] = lsbdistcodename
        end

        if lsbdistid = get_lsbdistid
          lsb_hash["distid"] = lsbdistid
        end

        if lsbdistdescription = get_lsbdistdescription
          lsb_hash["distdescription"] = lsbdistdescription
        end

        if lsbrelease = get_lsbrelease
          lsb_hash["release"] = lsbrelease
        end

        if lsbdistrelease = get_lsbdistrelease
          lsb_hash["distrelease"] = lsbdistrelease
        end

        if lsbmajdistrelease = get_lsbmajdistrelease
          lsb_hash["majdistrelease"]  = lsbmajdistrelease
        end

        if lsbminordistrelease = get_lsbminordistrelease
          lsb_hash["minordistrelease"]  = lsbminordistrelease
        end
        lsb_hash
      end

      def collect_lsb_information
        @lsb_data ||= Facter::Core::Execution.exec("lsb_release -cidvr 2>/dev/null")
        @data_hash = {}

        if @lsb_data && @data_hash.empty?
          @lsb_data.split("\n").each do |element|
            lsbvar, value = element.split("\t")
            lsbvar.gsub!(":", "")
            @data_hash["#{lsbvar}"] = value
          end
        end

        @data_hash unless @data_hash.empty?
      end

      private

      # Sequentially searches the filesystem for the existence of a release file
      #
      # @return [String, NilClass]
      def get_operatingsystem_with_release_files
        operatingsystem = nil
        release_files = {
          "AristaEOS"   => "/etc/Eos-release",
          "Debian"      => "/etc/debian_version",
          "Gentoo"      => "/etc/gentoo-release",
          "Fedora"      => "/etc/fedora-release",
          "Mageia"      => "/etc/mageia-release",
          "Mandriva"    => "/etc/mandriva-release",
          "Mandrake"    => "/etc/mandrake-release",
          "MeeGo"       => "/etc/meego-release",
          "Archlinux"   => "/etc/arch-release",
          "Manjarolinux"=> "/etc/manjaro-release",
          "OracleLinux" => "/etc/oracle-release",
          "OpenWrt"     => "/etc/openwrt_release",
          "Alpine"      => "/etc/alpine-release",
          "VMWareESX"   => "/etc/vmware-release",
          "Bluewhite64" => "/etc/bluewhite64-version",
          "Slamd64"     => "/etc/slamd64-version",
          "Slackware"   => "/etc/slackware-version"
        }

        release_files.each do |os, releasefile|
          if FileTest.exists?(releasefile)
            operatingsystem = os
          end
        end

        unless operatingsystem
          if FileTest.exists?("/etc/enterprise-release")
            if FileTest.exists?("/etc/ovs-release")
              operatingsystem = "OVS"
            else
              operatingsystem = "OEL"
            end
          elsif FileTest.exists?("/etc/redhat-release")
            operatingsystem = get_redhat_operatingsystem_name
          elsif FileTest.exists?("/etc/SuSE-release")
            operatingsystem = get_suse_operatingsystem_name
          elsif FileTest.exists?("/etc/system-release")
            operatingsystem = "Amazon"
          end
        end

        operatingsystem
      end

      # Uses a regex search on /etc/redhat-release to determine OS
      #
      # @return [String]
      def get_redhat_operatingsystem_name
        txt = File.read("/etc/redhat-release")
        matches = {
          "CentOS"     => "centos",
          "Scientific" => "Scientific",
          "CloudLinux" => "^cloudlinux",
          "PSBM"       => "^Parallels Server Bare Metal",
          "Ascendos"   => "Ascendos",
          "XenServer"  => "^XenServer",
          "XCP"        => "XCP"
        }

        if txt =~ /CERN/
          "SLC"
        else
          match = regex_search_release_file_for_operatingsystem(matches, txt)
          match = "RedHat" if match == nil

          match
        end
      end

      # Uses a regex search on /etc/SuSE-release to determine OS
      #
      # @return [String]
      def get_suse_operatingsystem_name
        txt = File.read("/etc/SuSE-release")
        matches = {
          "SLES"     => "^SUSE LINUX Enterprise Server",
          "SLED"     => "^SUSE LINUX Enterprise Desktop",
          "OpenSuSE" => "^openSUSE"
        }
        match = regex_search_release_file_for_operatingsystem(matches, txt)
        match = "SuSE" if match == nil

        match
      end

      # Iterates over potential matches from a hash argument and returns
      # result of search
      #
      # @return [String, NilClass]
      def regex_search_release_file_for_operatingsystem(regex_os_hash, filecontent)
        match = nil
        regex_os_hash.each do |os, regex|
          match = os if filecontent =~ /#{regex}/i
        end

        match
      end

      # Read release files to determine operatingsystemrelease
      #
      # @return [String]
      def get_alpine_release_with_release_file
        if release = Facter::Util::FileRead.read('/etc/alpine-release')
          release.sub!(/\s*$/, '')
          release
        end
      end

      def get_arista_release_with_release_file
        if release = Facter::Util::FileRead.read('/etc/Eos-release')
          if match = /\d+\.\d+(:?\.\d+)?[A-M]?$/.match(release)
            match[0]
          end
        end
      end

      def get_amazon_release_with_lsb
        if lsbdistrelease = get_lsbdistrelease
          lsbdistrelease
        else
          if release = Facter::Util::FileRead.read('/etc/system-release')
            if match = /\d+\.\d+/.match(release)
              match[0]
            end
          end
        end
      end

      def get_bluewhite_release_with_release_file
        if release = Facter::Util::FileRead.read('/etc/bluewhite64-version')
          if match = /^\s*\w+\s+(\d+)\.(\d+)/.match(release)
            match[1] + "." + match[2]
          else
            "unknown"
          end
        end
      end

      def get_redhatish_release_with_release_file
        case get_operatingsystem
        when "CentOS", "RedHat", "Scientific", "SLC", "Ascendos", "CloudLinux", "PSBM", "XenServer"
          releasefile = "/etc/redhat-release"
        when "Fedora"
          releasefile = "/etc/fedora-release"
        when "MeeGo"
          releasefile = "/etc/meego-release"
        when "OracleLinux"
          releasefile = "/etc/oracle-release"
        when "OEL", "oel"
          releasefile = "/etc/enterprise-release"
        when "OVS", "ovs"
          releasefile = "/etc/ovs-release"
        end

        if release = Facter::Util::FileRead.read(releasefile)
          line = release.split("\n").first.chomp
          if match = /\(Rawhide\)$/.match(line)
            "Rawhide"
          elsif match = /release (\d[\d.]*)/.match(line)
            match[1]
          end
        end
      end

      def get_debian_release_with_release_file
        if release = Facter::Util::FileRead.read('/etc/debian_version')
          release.sub!(/\s*$/, '')
          release
        end
      end

      def get_linux_mint_release_with_release_file
        regex_search_releasefile_for_release(/RELEASE\=(\d+)/, "/etc/linuxmint/info")
      end

      def get_mageia_release_with_release_file
        regex_search_releasefile_for_release(/Mageia release ([0-9.]+)/, "/etc/mageia-release")
      end

      def get_openwrt_release_with_release_file
        regex_search_releasefile_for_release(/^(\d+\.\d+.*)/, "/etc/openwrt_version")
      end

      def get_slackware_release_with_release_file
        regex_search_releasefile_for_release(/Slackware ([0-9.]+)/, "/etc/slackware-version")
      end

      def get_slamd64_release_with_release_file
        regex_search_releasefile_for_release(/^\s*\w+\s+(\d+)\.(\d+)/, "/etc/slamd64-version")
      end

      def get_ubuntu_release_with_release_file
        if release = Facter::Util::FileRead.read('/etc/lsb-release')
          if match = release.match(/DISTRIB_RELEASE=((\d+.\d+)(\.(\d+))?)/)
            # Return only the major and minor version numbers.  This behavior must
            # be preserved for compatibility reasons.
            match[2]
          end
        end
      end

      def get_vmwareESX_release_with_release_file
        release = Facter::Core::Execution.exec('vmware -v')
        if match = /VMware ESX .*?(\d.*)/.match(release)
          match[1]
        end
      end

      def get_suse_release_with_release_file
        if release = Facter::Util::FileRead.read('/etc/SuSE-release')
          if match = /^VERSION\s*=\s*(\d+)/.match(release)
            releasemajor = match[1]
            if match = /^PATCHLEVEL\s*=\s*(\d+)/.match(release)
              releaseminor = match[1]
            elsif match = /^VERSION\s=.*.(\d+)/.match(release)
              releaseminor = match[1]
            else
              releaseminor = "0"
            end
            releasemajor + "." + releaseminor
          else
            "unknown"
          end
        end
      end

      def regex_search_releasefile_for_release(regex, releasefile)
        if release = Facter::Util::FileRead.read(releasefile)
          if match = release.match(regex)
            match[1]
          end
        end
      end
    end
  end
end
