#include "cfacterlib.h"

#include <iostream>
#include <stdlib.h>

using namespace std;

int main(int argc, char **argv)
{
    // facter version itself -- report? if so, report facter 'equivalent'?
    cout << "facterversion => 1.7.3" << endl;

    dump_network_facts();
    dump_kernel_facts();
    dump_blockdevice_facts();
    dump_lsb_facts();
    dump_uptime_facts();
    dump_virtual_facts();
    dump_hardwired_facts();
    dump_misc_facts();
    dump_ruby_lib_versions();
    dump_mem_facts();
    dump_selinux_facts();
    exit(0);
}
