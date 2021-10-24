# frozen_string_literal: true

module Facter
  module Util
    module Aix
      module InfoExtractor
        MEGABYTES_EXPONENT = 1024**2
        GIGABYTES_EXPONENT = 1024**3
        PROPERTIES = {
          lslv: [
            'LOGICAL VOLUME:',
            'VOLUME GROUP:',
            'LV IDENTIFIER:',
            'PERMISSION:',
            'VG STATE:',
            'LV STATE:',
            'TYPE:',
            'WRITE VERIFY:',
            'MAX LPs:',
            'PP SIZE:',
            'COPIES:',
            'SCHED POLICY:',
            'LPs:',
            'PPs:',
            'STALE PPs:',
            'BB POLICY:',
            'INTER-POLICY:',
            'RELOCATABLE:',
            'INTRA-POLICY:',
            'UPPER BOUND:',
            'MOUNT POINT:',
            'LABEL:',
            'MIRROR WRITE CONSISTENCY:',
            'EACH LP COPY ON A SEPARATE PV ?:',
            'Serialize IO ?:'
          ],
          lspv: [
            'PHYSICAL VOLUME:',
            'VOLUME GROUP:',
            'PV IDENTIFIER:',
            'VG IDENTIFIER',
            'PV STATE:',
            'STALE PARTITIONS:',
            'ALLOCATABLE:',
            'PP SIZE:',
            'LOGICAL VOLUMES:',
            'TOTAL PPs:',
            'VG DESCRIPTORS:',
            'FREE PPs:',
            'HOT SPARE:',
            'USED PPs:',
            'MAX REQUEST:',
            'FREE DISTRIBUTION:',
            'USED DISTRIBUTION:',
            'MIRROR POOL:'
          ]
        }.freeze

        def self.extract(content, cmd)
          property_hash = {}
          properties = PROPERTIES[cmd]
          properties.each do |property|
            str = (properties - [property]).join('|')
            matcher = content.match(/#{Regexp.escape(property)}([^\n]*?)(#{str}|\n|$)/s)
            if matcher
              value = matcher[1].strip
              property_hash[property.split(':').first] = value
            end
          end
          property_hash
        end
      end
    end
  end
end
