require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Part do
  before :all do
    @p = Part.new(
      Dynamics::MP,
      notes: Note.split_parse("/4Bb2 /8 /8F3= /2F3 /4Bb2 /8 /8F3= /2F3"),
      dynamic_changes: {
        1 => Change::Immediate.new(Dynamics::PP),
        2 => Change::Gradual.new(Dynamics::FF, 2.0)
      }
    )
    
    @h = @p.pack
  end

  describe '#pack' do
    it 'should produce a hash' do
      @h.should be_a Hash
    end
    
    it 'should return a hash with keys: "notes", "start_dynamic", and "dynamic_changes"' do
      @h.keys.should include("notes")
      @h.keys.should include("start_dynamic")
      @h.keys.should include("dynamic_changes")
    end
    
    it 'should pack notes into a string' do
      @h['notes'].should be_a String
    end
    
    it 'should pack start dynamic as plain numeric value' do
      @h['start_dynamic'].should be_a Numeric
    end
    
    it 'should pack dynamic changes as whatver type Change#pack returns' do
      @h['dynamic_changes'].each do |offset,packed_v|
        change_v = @p.dynamic_changes[offset]
        t = change_v.pack.class
        packed_v.should be_a t
      end
    end
  end
  
  describe '.unpack' do
    before :all do
      @p2 = Part.unpack @h
    end
    
    it 'should return a Part' do
      @p2.should be_a Part
    end
    
    it 'should successfuly unpack the notes' do
      @p2.notes.should eq @p.notes
    end
    
    it 'should successfuly unpack the start dynamic' do
      @p2.start_dynamic.should eq @p.start_dynamic
    end
    
    it 'should successfuly unpack the dynamic changes' do
      @p2.dynamic_changes.should eq @p.dynamic_changes
    end
  end
end
