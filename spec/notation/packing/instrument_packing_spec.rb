require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Instrument do
  before :all do
    @p = Instrument.new(
      'My Instrument',
      [ Instrument::TREBLE, Instrument::BASS],
      43,
      -7
    )
    
    @h = @p.pack
  end

  describe '#pack' do
    it 'should produce a hash' do
      @h.should be_a Hash
    end
    
    it 'should return a hash with keys: "name", "clefs", "midi_num", and "transpose_interval"' do
      @h.keys.should include("name")
      @h.keys.should include("clefs")
      @h.keys.should include("midi_num")
      @h.keys.should include("transpose_interval")
    end
    
    it 'should pack name as a string' do
      @h['name'].should be_a String
    end
    
    it 'should pack clefs as an array' do
      @h['clefs'].should be_a Array
    end
    
    it 'should pack midi_num as integer' do
      @h['midi_num'].should be_a Integer
    end

    it 'should pack transpose_interval as integer' do
      @h['transpose_interval'].should be_a Integer
    end
  end
  
  describe '.unpack' do
    before :all do
      @p2 = Instrument.unpack @h
    end
    
    it 'should return a Instrument' do
      @p2.should be_a Instrument
    end
    
    it 'should successfully unpack the name' do
      @p2.name.should eq @p.name
    end
    
    it 'should successfully unpack the clefs' do
      @p2.clefs.should eq @p.clefs
    end
    
    it 'should successfully unpack the midi_num' do
      @p2.midi_num.should eq @p.midi_num
    end

    it 'should successfully unpack the transpose_interval' do
      @p2.transpose_interval.should eq @p.transpose_interval
    end
  end
end
