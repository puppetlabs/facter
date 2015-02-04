require 'spec_helper'
require 'facter/util/operatingsystem'

describe Facter::Util::Operatingsystem do
  describe "reading the os-release file" do

    it "correctly parses the file on Cumulus Linux"  do
      values = described_class.os_release(my_fixture('cumuluslinux.txt'))

      expect(values).to eq({
        'NAME' => "Cumulus Linux",
        'VERSION_ID' => "1.5.2",
        'VERSION' => "1.5.2-28283a7-201311181623-final",
        'PRETTY_NAME' => "Cumulus Linux",
        'ID' => "cumulus-linux",
        'ID_LIKE' => "debian",
        'CPE_NAME' => "cpe:/o:cumulusnetworks:cumulus_linux:1.5.2-28283a7-201311181623-final",
        'HOME_URL' => "http://www.cumulusnetworks.com/",
      })
    end

    it "correctly parses the file on CoreOS Linux"  do
      values = described_class.os_release(my_fixture('coreos.txt'))

      expect(values).to eq({
        'NAME' => "CoreOS",
        'VERSION_ID' => "575.0.0",
        'VERSION' => "575.0.0",
        'PRETTY_NAME' => "CoreOS 575.0.0",
        'ID' => "coreos",
        'HOME_URL' => "https://coreos.com/",
        'BUG_REPORT_URL' => "https://github.com/coreos/bugs/issues",
        'ANSI_COLOR' => "1;32",
      })
    end

    it "correctly parses the file on Sabayon" do
      values = described_class.os_release(my_fixture('sabayon.txt'))

      expect(values).to eq({
        "NAME" => "Sabayon",
        "ID" => "sabayon",
        "PRETTY_NAME" => "Sabayon/Linux",
        "ANSI_COLOR" => "1;32",
        "HOME_URL" => "http://www.sabayon.org/",
        "SUPPORT_URL" => "http://forum.sabayon.org/",
        "BUG_REPORT_URL" => "https://bugs.sabayon.org/",
      })
    end

    it "correctly parses the file on Debian Wheezy" do
      values = described_class.os_release(my_fixture('wheezy.txt'))

      expect(values).to eq({
        "PRETTY_NAME" => "Debian GNU/Linux 7 (wheezy)",
        "NAME" => "Debian GNU/Linux",
        "VERSION_ID" => "7",
        "VERSION" => "7 (wheezy)",
        "ID" => "debian",
        "ANSI_COLOR" => "1;31",
        "HOME_URL" => "http://www.debian.org/",
        "SUPPORT_URL" => "http://www.debian.org/support/",
        "BUG_REPORT_URL" => "http://bugs.debian.org/",
      })
    end

    it "correctly parses the file on Debian Wheezy" do
      values = described_class.os_release(my_fixture('wheezy.txt'))

      expect(values).to eq({
        "PRETTY_NAME" => "Debian GNU/Linux 7 (wheezy)",
        "NAME" => "Debian GNU/Linux",
        "VERSION_ID" => "7",
        "VERSION" => "7 (wheezy)",
        "ID" => "debian",
        "ANSI_COLOR" => "1;31",
        "HOME_URL" => "http://www.debian.org/",
        "SUPPORT_URL" => "http://www.debian.org/support/",
        "BUG_REPORT_URL" => "http://bugs.debian.org/",
      })
    end


    it "correctly parses the file on RedHat 7" do
      values = described_class.os_release(my_fixture('redhat-7.txt'))
      expect(values).to eq({
        "NAME" => "Red Hat Enterprise Linux Everything",
        "VERSION" => "7.0 (Maipo)",
        "ID" => "rhel",
        "VERSION_ID" => "7.0",
        "PRETTY_NAME" => "Red Hat Enterprise Linux Everything 7.0 (Maipo)",
        "ANSI_COLOR" => "0;31",
        "CPE_NAME" => "cpe:/o:redhat:enterprise_linux:7.0:beta:everything",
        "REDHAT_BUGZILLA_PRODUCT" => "Red Hat Enterprise Linux 7",
        "REDHAT_BUGZILLA_PRODUCT_VERSION" => "7.0",
        "REDHAT_SUPPORT_PRODUCT" => "Red Hat Enterprise Linux",
        "REDHAT_SUPPORT_PRODUCT_VERSION" => "7.0",
      })
    end

    it "does not try to read an unreadable '/etc/os-release' file" do
      File.expects(:readable?).with('/some/nonexistent/file').returns false

      expect(described_class.os_release('/some/nonexistent/file')).to be_empty
    end
  end
end
