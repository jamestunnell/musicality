require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

tempo_score = Score::Tempo.new(FOUR_FOUR,120) do |s|
  s.title "The best song ever"
  s.composer "James T."

  s.meter_changes[1] = Change::Immediate.new(THREE_FOUR)
  s.meter_changes[7] = Change::Immediate.new(SIX_EIGHT)
  
  s.tempo_changes[2] = Change::Immediate.new(100)
  s.tempo_changes[4] = Change::Gradual.linear(70,2)
  s.tempo_changes[9] = Change::Gradual.sigmoid(99,5).trim(2,2)
  
  s.program += [0...2, 0...2,2...4,0...2]
  s.parts["lead"] = Part.new(Dynamics::MF) do |p|
    riff = "/6Bb3 /4 /12Db4= /6Db4= /36Db4 /36Eb4 /36Db4 /6Ab3 /12Db4 \
            /6Bb3 /4 /12Db4= /4Db4=                      /8Db4= /8C4".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
    p.dynamic_changes[1] = Change::Gradual.linear(Dynamics::F,2)
  end
  
  s.parts["bass"] = Part.new(Dynamics::MP) do |p|
    riff = "/6Bb2 /4 /3Ab2 /6F2 /12Ab2 \
            /6Bb2 /4 /3Ab2 /4Ab2".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
    p.dynamic_changes[1] = Change::Immediate.new(Dynamics::F)
    p.dynamic_changes[3] = Change::Gradual.sigmoid(Dynamics::PP,4).trim(1,1)
  end
end

timed_score = Score::Timed.new do |s|
  s.program = tempo_score.program
  s.parts = tempo_score.parts
  s.title tempo_score.title
  s.composer tempo_score.composer
end

[ tempo_score, timed_score ].each do |score|
  describe score.class do
    before :all do
      @score = score
      @h = @score.pack
    end
    
    describe '#pack' do
      it 'should return a hash' do
        @h.should be_a Hash
      end
      
      it 'should return a hash with keys: "type","parts","program","start_key", and "key_changes"' do
        ["type","parts","program","start_key","key_changes"].each do |key|
          @h.should have_key(key)
        end
      end
      
      it 'should pack program as an array with same size' do
        @h['program'].should be_a Array
        @h['program'].size.should eq(@score.program.size)
      end
      
      it 'should pack program segments as strings' do
        @h['program'].each {|x| x.should be_a String }
      end
  
      it 'should pack parts as hash' do
        @h['parts'].should be_a Hash
      end
      
      it 'should pack parts as whatever Part#pack returns' do
        @score.parts.each do |name,part|
          packing = part.pack
          @h['parts'][name].should eq packing
        end
      end

      it 'should add title to packing' do
        @h.should have_key "title"
        @h["title"].should eq @score.title
      end

      it 'should add composer to packing' do
        @h.should have_key "composer"
        @h["composer"].should eq @score.composer
      end

      it 'should pack start_key as whatever Key#pack returns' do
        @h['start_key'].should eq @score.start_key.pack
      end

      it 'should pack key_changes as whatever Key#pack returns' do
        @score.key_changes.each do |off,key|
          @h['key_changes'][off].should eq key.pack
        end
      end
    end
    
    describe '.unpack' do
      before :all do
        @score2 = score.class.unpack @h
      end
      
      it "should return a #{score.class}" do
        @score2.should be_a score.class
      end
      
      it 'should successfuly unpack the parts' do
        @score2.parts.should eq @score.parts
      end
      
      it 'should successfuly unpack the program' do
        @score2.program.should eq @score.program
      end

      it 'should successfuly unpack the title' do
        @score2.title.should eq @score.title
      end

      it 'should successfuly unpack the composer' do
        @score2.composer.should eq @score.composer
      end

      it 'should successfully unpack the start key' do
        @score2.start_key.should eq @score.start_key
      end

      it 'should successfuly unpack the key changes' do
        @score2.key_changes.should eq @score.key_changes
      end
    end
  end
end

describe Score::Tempo do
  before :all do
    @score = tempo_score
    @h = @score.pack
  end
  
  describe '#pack' do    
    it 'should return a hash with keys: "start_tempo" and "tempo_changes"' do
      ["start_tempo","tempo_changes"].each {|key| @h.should have_key(key) }
    end

    it 'should pack start tempo as numeric' do
      @h['start_tempo'].should be_a Numeric
    end

    it 'should pack tempo changes as a hash' do
      @h['tempo_changes'].should be_a Hash
    end
    
    it 'should pack tempo changes values using Change#pack' do
      @h['tempo_changes'].each do |offset,packed_v|
        change = @score.tempo_changes[offset]
        packed_v.should eq(change.pack)
      end
    end

    it 'should return a hash with keys: "start_meter" and "meter_changes"' do
      ["start_meter","meter_changes"].each { |key| @h.should have_key(key) }
    end
    
    it 'should set "type" key to "Tempo"' do
      @h["type"].should eq("Tempo")
    end
    
    it 'should pack start meter as whatever Meter#pack returns' do
      @h['start_meter'].should eq @score.start_meter.pack
    end

    it 'should pack meter changes as whatever Meter#pack returns' do
      @h['meter_changes'].each do |off,packed_v|
        packed_v.should eq @score.meter_changes[off].pack {|v| v.pack}
      end
    end
  end
  
  describe '.unpack' do
    before :all do
      @score2 = Score::Tempo.unpack @h
    end
    
    it 'should successfuly unpack the start tempo' do
      @score2.start_tempo.should eq @score.start_tempo
    end
    
    it 'should successfuly unpack the tempo changes' do
      @score2.tempo_changes.should eq @score.tempo_changes
    end

    it 'should successfuly unpack the start meter' do
      @score2.start_meter.should eq @score.start_meter
    end

    it 'should successfuly unpack the meter changes' do
      @score2.meter_changes.should eq @score.meter_changes
    end
  end
end

describe Score::Timed do
  before :all do
    @score = timed_score
    @h = @score.pack
  end
  
  describe '#pack' do
    it 'should set "type" key to "Timed"' do
      @h["type"].should eq("Timed")
    end    
  end
end

describe Score do
  describe '.unpack' do
    [ timed_score, tempo_score ].each do |score|
      context "given packing from a #{score.class} object" do
        before :all do
          @packing = score.pack
          @score2 = Score.unpack(@packing)
        end
        
        it "should return a #{score.class} object equal to original" do
          @score2.should be_a score.class
          @score2.should eq(score)
        end
        
        it "should return a score equal to what #{score.class}.unpack returns" do
          @score2.should eq(score.class.unpack(@packing))
        end
      end
    end
  end
end
