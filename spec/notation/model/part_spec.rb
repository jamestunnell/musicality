require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Part do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      p = Part.new(Dynamics::MP)
      p.notes.should be_empty
      p.dynamic_changes.should be_empty
    end
    
    it "should assign parameters given during construction" do
      p = Part.new(Dynamics::PPP)
      p.start_dynamic.should eq Dynamics::PPP
      
      notes = [Note::whole([A2]), Note::half]
      dcs = { "1/2".to_r => Change::Immediate.new(Dynamics::P), 1 => Change::Gradual.sigmoid(Dynamics::MF,1) }
      p = Part.new(Dynamics::FF, notes: notes, dynamic_changes: dcs)
      p.notes.should eq notes
      p.dynamic_changes.should eq dcs

      p = Part.new(Dynamics::P, instrument: Instruments::ELECTRIC_PIANO_1)
      p.instrument.should eq Instruments::ELECTRIC_PIANO_1
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      p = Samples::SAMPLE_PART
      YAML.load(p.to_yaml).should eq p
    end
  end
  
  describe '#valid?' do
    { 'negative start dynamic' => [-0.01],
      'start dynamic > 1' => [1.01],
      #'dynamic change offsets outside 0..d' => [
      #  0.5, :notes => [ Note::whole ],
      #  :dynamic_changes => { 1.2 => Change::Immediate.new(0.5) }],
      #'dynamic change offsets outside 0..d' => [
      #  0.5, :notes => [ Note::whole ],
      #  :dynamic_changes => { -0.2 => Change::Immediate.new(0.5) }],
      'dynamic change values outside 0..1' => [
        0.5, :notes => [ Note::whole ],
        :dynamic_changes => { 0.2 => Change::Immediate.new(-0.01), 0.3 => Change::Gradual.linear(1.01,0.2) }],
    }.each do |context_str, args|
      context context_str do
        it 'should return false' do
          Part.new(*args).should be_invalid
        end
      end
    end
    
    {
      'valid notes' => [ Dynamics::PP,
        :notes => [ Note::whole, quarter([C5]) ]],
      'valid dynamic values' => [ Dynamics::MF,
        :notes => [ Note::whole([C4]), Note::quarter ],
        :dynamic_changes => {
          0.5 => Change::Immediate.new(Dynamics::MP),
          1.2 => Change::Gradual.linear(Dynamics::FF, 0.05) } ],
    }.each do |context_str, args|
      context context_str do
        it 'should return true' do
          part = Part.new(*args)
          part.should be_valid
        end
      end
    end
  end
end
