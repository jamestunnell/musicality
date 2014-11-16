require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

note_score = NoteScore.new(Tempo::QNPM.new(30)) do |s|
  s.program = Program.new([0...2, 0...2,2...4,0...2])
  s.parts["lead"] = Part.new(Dynamics::MF) do |p|
    riff = "/6Bb3 /4 /12Db4= /6Db4= /36Db4 /36Eb4 /36Db4 /6Ab3 /12Db4 \
            /6Bb3 /4 /12Db4= /4Db4=                      /8=Db4 /8C4".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
  end
  
  s.parts["bass"] = Part.new(Dynamics::MP) do |p|
    riff = "/6Bb2 /4 /3Ab2 /6F2 /12Ab2 \
            /6Bb2 /4 /3Ab2 /4Ab2".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
  end
end

measure_score = MeasureScore.new(FOUR_FOUR,Tempo::BPM.new(120)) do |s|
  s.program = Program.new([0...2, 0...2,2...4,0...2])
  s.parts["lead"] = Part.new(Dynamics::MF) do |p|
    riff = "/6Bb3 /4 /12Db4= /6Db4= /36Db4 /36Eb4 /36Db4 /6Ab3 /12Db4 \
            /6Bb3 /4 /12Db4= /4Db4=                      /8=Db4 /8C4".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
  end
  
  s.parts["bass"] = Part.new(Dynamics::MP) do |p|
    riff = "/6Bb2 /4 /3Ab2 /6F2 /12Ab2 \
            /6Bb2 /4 /3Ab2 /4Ab2".to_notes
    p.notes = riff + riff.map {|n| n.transpose(2) }
  end
end

describe 'pack_score' do
  context 'give a NoteScore' do
    before :all do
      @packing = pack_score(note_score)
    end
    
    it 'should produce a Hash' do
      @packing.should be_a Hash
    end
    
    it 'should add a "type" key' do
      @packing.should have_key("type")
    end
    
    it 'should be otherwise equal to the Hash produced by NoteScore#pack' do
      note_score.pack.each do |k,v|
        @packing.should have_key(k)
        @packing[k].should eq(v)
      end
    end
  end
  
  context 'give a MeasureScore' do
    before :all do
      @packing = pack_score(measure_score)
    end
    
    it 'should produce a Hash' do
      @packing.should be_a Hash
    end
    
    it 'should add a "type" key' do
      @packing.should have_key("type")
    end
    
    it 'should be otherwise equal to the Hash produced by MeasureScore#pack' do
      measure_score.pack.each do |k,v|
        @packing.should have_key(k)
        @packing[k].should eq(v)
      end
    end
  end
end

describe 'unpack_score' do
  context 'given packing from NoteScore#pack' do
    it 'should return a NoteScore object equal to original' do
      packing = pack_score(note_score)
      score = unpack_score(packing)
      score.should be_a NoteScore
      score.should eq(note_score)
    end
  end
  
  context 'given packing from MeasureScore#pack' do
    it 'should return a NoteScore object equal to original' do
      packing = pack_score(measure_score)
      score = unpack_score(packing)
      score.should be_a MeasureScore
      score.should eq(measure_score)
    end
  end
end
