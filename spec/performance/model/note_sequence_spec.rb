require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NoteSequence do
  describe '#initialize' do
    it 'should assign given start, stop, pitches and attacks' do
      start, stop = 15, 22
      pitches = { 15 => F2, 16 => G2, 16.1 => Ab2, 21.99 => C2 }
      attacks = { 15 => ACCENTED, 17 => UNACCENTED, 18 => ACCENTED }
      seq = NoteSequence.new(start,stop,pitches,attacks)
      seq.start.should eq(start)
      seq.stop.should eq(stop)
      seq.pitches.should eq(pitches)
      seq.attacks.should eq(attacks)
    end
    
    it 'should raise ArgumentError if start offset >= stop offset' do
      expect do
        NoteSequence.new(20,19, { 20 => C4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no pitches are given' do
      expect do
        NoteSequence.new(20,21, {}, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no attacks are given' do
      expect do
        NoteSequence.new(20,21, { 20 => C4 }, {})
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no start pitch is given' do
      expect do
        NoteSequence.new(20,21, { 20.1 => C4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if no start attack is given' do
      expect do
        NoteSequence.new(20,21, { 20 => C4 }, { 20.1 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if any pitch offset is not between start..stop' do
      expect do
        NoteSequence.new(20,21, { 20 => C4, 21.01 => D4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
      
      expect do
        NoteSequence.new(20,21, { 20 => C4, 19.99 => D4 }, { 20 => UNACCENTED })
      end.to raise_error(ArgumentError)
    end
    
    it 'should raise ArgumentError if any attack offset is not between start..stop' do
      expect do
        NoteSequence.new(20,21, { 20 => C4 }, { 20 => UNACCENTED, 21.01 => ACCENTED })
      end.to raise_error(ArgumentError)
      
      expect do
        NoteSequence.new(20,21, { 20 => C4 }, { 20 => UNACCENTED, 19.99 => ACCENTED })
      end.to raise_error(ArgumentError)
    end
  end
  
  describe '.from_elements' do
    it 'should raise ArgumentError if no elements are given' do
      expect { NoteSequence.from_elements(2,[]) }.to raise_error(ArgumentError)
    end
    
    context 'single element' do
      before :all do
        @offset = 0
        @el = FinalElement.new(2, C2, true, NORMAL)
        @seq = NoteSequence.from_elements(@offset, [ @el ])
        
      end
      
      it 'should return a NoteSequence' do
        @seq.should be_a NoteSequence
      end
      
      it 'should set start offset to given offset' do
        @seq.start.should eq(@offset)
      end
      
      it 'should set stop offset no more than "duration of first element" away from start' do
        (@seq.stop - @seq.start).should be <= @el.duration
      end
      
      it 'should set start pitch according to element pitch' do
        @seq.pitches[@seq.start].should eq(@el.pitch)
      end
      
      it 'should set start attack according to element.accented' do
        @seq.attacks[@seq.start].accented?.should eq(@el.accented)
      end
    end
    
    context 'multi-element' do
      before :all do
        @offset = 1.5
        @els = [
          SlurredElement.new(1.0, A2, false),
          LegatoElement.new(1.1, B2, false),
          SlurredElement.new(1.2, C2, false),
          LegatoElement.new(1.3, B2, false),
          FinalElement.new(1.4, A2, false, NORMAL)
        ]
        @seq = NoteSequence.from_elements(@offset, @els)
      end
      
      it 'should place pitches according to element duration' do
        offset = @offset
        @els.each do |el|
          @seq.pitches.should have_key(offset)
          @seq.pitches[offset].should eq(el.pitch)
          offset += el.duration
        end
      end
      
      it 'should place attacks at beginning and following non-slur elements' do
        @seq.attacks.should have_key(@offset)
        
        offset = @offset + @els.first.duration
        (1...@els.size).each do |i|
          unless @els[i-1].slurred?
            @seq.attacks.should have_key(offset)
          end
          offset += @els[i].duration
        end
      end
    end
    
    context 'elements contain slur to same pitch' do
      it 'should not add same pitch nor attack for second element' do
        els = [ SlurredElement.new(1, C4, false), FinalElement.new(1, C4, false, NORMAL) ]
        seq = NoteSequence.from_elements(0, els)
        seq.pitches.should have_key(0)
        seq.pitches.should_not have_key(1)
        seq.attacks.should have_key(0)
        seq.attacks.should_not have_key(1)
      end
    end
  end
end
