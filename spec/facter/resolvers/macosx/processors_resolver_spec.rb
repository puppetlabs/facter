# frozen_string_literal: true

describe 'MacOSX ProcessorsResolver' do
  let(:logicalcount) { 4 }
  let(:models) do
    ['Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz', 'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz',
     'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz', 'Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz']
  end
  let(:physical_processors) { 1 }
  let(:speed_expected) { '2.30 GHz' }
  output = ['hw.logicalcpu_max: 4',
            'hw.physicalcpu_max: 1',
            'machdep.cpu.brand_string: Intel(R) Xeon(R) CPU E5-2697 v4 @ 2.30GHz',
            'hw.cpufrequency_max: 2300000000'].join("\n")
  before do
    allow(Open3)
      .to receive(:capture2)
      .with('sysctl hw.logicalcpu_max hw.physicalcpu_max machdep.cpu.brand_string hw.cpufrequency_max')
      .and_return(output)
  end
  it 'returns number of processors' do
    result = Facter::Resolvers::Macosx::Processors.resolve(:logicalcount)

    expect(result).to eq(logicalcount)
  end
  it 'returns number of physical processors' do
    result = Facter::Resolvers::Macosx::Processors.resolve(:physicalcount)

    expect(result).to eq(physical_processors)
  end

  it 'returns list of models' do
    result = Facter::Resolvers::Macosx::Processors.resolve(:models)

    expect(result).to eq(models)
  end
  it 'returns speed of processors' do
    result = Facter::Resolvers::Macosx::Processors.resolve(:speed)

    expect(result).to eq(speed_expected)
  end
end
