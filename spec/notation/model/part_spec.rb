require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

describe Part do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      p = Part.new(Dynamics::MP)
      expect(p.notes).to be_empty
      expect(p.dynamic_changes).to be_empty
    end

    it "should assign parameters given during construction" do
      p = Part.new(Dynamics::PPP)
      expect(p.start_dynamic).to eq Dynamics::PPP

      notes = [Note::whole([A2]), Note::half]
      dcs = { "1/2".to_r => Change::Immediate.new(Dynamics::P), 1 => Change::Gradual.sigmoid(Dynamics::MF,1) }
      p = Part.new(Dynamics::FF, notes: notes, dynamic_changes: dcs)
      expect(p.notes).to eq notes
      expect(p.dynamic_changes).to eq dcs

      p = Part.new(Dynamics::P, settings: [ "dummy" ])
      expect(p.settings).to eq [ "dummy" ]
    end
  end

  describe '#find_settings' do
    context 'settings is empty' do
      it 'should return nil' do
        expect(Part.new(Dynamics::P).find_settings(Integer)).to be_nil
      end
    end

    context 'one or more objects in settings' do
      before :all do
        @part = Part.new(Dynamics::MF, settings: [ 5, "boy" ])
      end

      context 'given class of object in settings' do
        it 'should return the object' do
          expect(@part.find_settings(Integer)).to be_a Integer
          expect(@part.find_settings(String)).to be_a String
        end
      end

      context 'given class not of any object in settings' do
        it 'should return nil' do
          expect(@part.find_settings(Float)).to be_nil
        end
      end
    end
  end

  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      p = Samples::SAMPLE_PART
      expect(YAML.load(p.to_yaml)).to eq p
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      notes = [Note::whole([A2]), Note::half]
      dcs = { "1/2".to_r => Change::Immediate.new(Dynamics::P), 1 => Change::Gradual.sigmoid(Dynamics::MF,1) }
      p = Part.new(Dynamics::FF, notes: notes, dynamic_changes: dcs, settings: [ "dummy" ])
      expect(p.pack).to be_a Hash
    end
  end

  describe 'unpack' do
    it 'should produce an object equal the original' do
      notes = [Note::whole([A2]), Note::half]
      dcs = { "1/2".to_r => Change::Immediate.new(Dynamics::P), 1 => Change::Gradual.sigmoid(Dynamics::MF,1) }
      p = Part.new(Dynamics::FF, notes: notes, dynamic_changes: dcs, settings: [ "dummy" ])
      p2 = Part.unpack p.pack
      expect(p2).to be_a Part
      expect(p2).to eq p
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
          expect(Part.new(*args)).to be_invalid
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
          expect(part).to be_valid
        end
      end
    end
  end
end
