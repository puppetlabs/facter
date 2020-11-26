# frozen_string_literal: true

describe Facter::Resolvers::Gce do
  let(:gce_metadata_url) { 'http://metadata.google.internal/computeMetadata/v1/?recursive=true&alt=json' }
  let(:gce_url_headers) { { "Metadata-Flavor": 'Google', "Accept": 'application/json' } }

  before do
    allow(Facter::Util::Resolvers::Http).to receive(:get_request)
      .with(gce_metadata_url, gce_url_headers)
      .and_return(http_response_body)
  end

  after do
    Facter::Resolvers::Gce.invalidate_cache
  end

  context 'when http request is successful' do
    let(:http_response_body) { load_fixture('gce').read }
    let(:value) do
      {
        'instance' => {
          'attributes' => {
          },
          'cpuPlatform' => 'Intel Broadwell',
          'description' => '',
          'disks' => [
            {
              'deviceName' => 'instance-3',
              'index' => 0,
              'interface' => 'SCSI',
              'mode' => 'READ_WRITE',
              'type' => 'PERSISTENT'
            }
          ],
          'guestAttributes' => {
          },
          'hostname' => 'instance-3.c.facter-performance-history.internal',
          'id' => 2_206_944_706_428_651_580,
          'image' => 'ubuntu-2004-focal-v20200810',
          'legacyEndpointAccess' => {
            '0.1' => 0,
            'v1beta1' => 0
          },
          'licenses' => [
            {
              'id' => '2211838267635035815'
            }
          ],
          'machineType' => 'n1-standard-2',
          'maintenanceEvent' => 'NONE',
          'name' => 'instance-3',
          'networkInterfaces' => [
            {
              'accessConfigs' => [
                {
                  'externalIp' => '34.89.230.102',
                  'type' => 'ONE_TO_ONE_NAT'
                }
              ],
              'dnsServers' => [
                '169.254.169.254'
              ],
              'forwardedIps' => [],
              'gateway' => '10.156.0.1',
              'ip' => '10.156.0.4',
              'ipAliases' => [],
              'mac' => '42:01:0a:9c:00:04',
              'mtu' => 1460,
              'network' => 'default',
              'subnetmask' => '255.255.240.0',
              'targetInstanceIps' => []
            }
          ],
          'preempted' => 'FALSE',
          'remainingCpuTime' => -1,
          'scheduling' => {
            'automaticRestart' => 'TRUE',
            'onHostMaintenance' => 'MIGRATE',
            'preemptible' => 'FALSE'
          },
          'serviceAccounts' => {
            '728618928092-compute@developer.gserviceaccount.com' => {
              'aliases' => [
                'default'
              ],
              'email' => '728618928092-compute@developer.gserviceaccount.com',
              'scopes' => [
                'https://www.googleapis.com/auth/devstorage.read_only',
                'https://www.googleapis.com/auth/logging.write',
                'https://www.googleapis.com/auth/monitoring.write',
                'https://www.googleapis.com/auth/servicecontrol',
                'https://www.googleapis.com/auth/service.management.readonly',
                'https://www.googleapis.com/auth/trace.append'
              ]
            },
            'default' => {
              'aliases' => [
                'default'
              ],
              'email' => '728618928092-compute@developer.gserviceaccount.com',
              'scopes' => [
                'https://www.googleapis.com/auth/devstorage.read_only',
                'https://www.googleapis.com/auth/logging.write',
                'https://www.googleapis.com/auth/monitoring.write',
                'https://www.googleapis.com/auth/servicecontrol',
                'https://www.googleapis.com/auth/service.management.readonly',
                'https://www.googleapis.com/auth/trace.append'
              ]
            }
          },
          'tags' => [],
          'virtualClock' => {
            'driftToken' => '0'
          },
          'zone' => 'europe-west3-c'
        },
        'oslogin' => {
          'authenticate' => {
            'sessions' => {
            }
          }
        },
        'project' => {
          'attributes' => {
            'ssh-keys' => 'john_doe:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDA9D8Op48TtEiDmb+Gtna3Bs9B' \
              " google-ssh {\"userName\":\"john.doe@puppet.com\",\"expireOn\":\"2020-08-13T12:17:19+0000\"}\n"
          },
          'numericProjectId' => 728_618_928_092,
          'projectId' => 'facter-performance-history'
        }
      }
    end

    it 'returns gce data' do
      result = Facter::Resolvers::Gce.resolve(:metadata)

      expect(result).to eq(value)
    end
  end

  context 'when http request fails' do
    let(:http_response_body) { 'Request failed with error code: 404' }

    it 'returns nil' do
      result = Facter::Resolvers::Gce.resolve(:metadata)

      expect(result).to be(nil)
    end
  end
end
