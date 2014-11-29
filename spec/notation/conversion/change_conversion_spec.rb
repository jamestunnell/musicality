require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  describe '#offsets' do
    it 'should return array with just the given base offset' do
      c = Change::Immediate.new(12)
      c.offsets(44).should eq([44])
    end
  end
  
  describe '#remap' do
    it 'should return a clone of the change' do
      c = Change::Immediate.new(12)
      c2 = c.remap(1,{})
      c2.should eq(c)
      c2.should_not be c
    end
  end
  
  describe '#to_transition' do
    it 'should return an immediate transition' do
      ch = Change::Immediate.new(20)
      f = ch.to_transition(0,0)
      f.should be_a Transition::Immediate
      f.at(0).should eq(20)
    end
  end
end

describe Change::Gradual do
  before :all do
    @change = Change::Gradual.linear(100,1.5)
    @base = 25.5
  end
  
  describe '#offsets' do
    before :all do
      @offsets = @change.offsets(@base)
    end
    
    it 'should return array with 2 elements' do
      @offsets.size.should eq(2)
    end
    
    it 'should include the given base offset' do
      @offsets.should include(@base)
    end
    
    it 'should include the base offset + duration' do
      @offsets.should include(@base + @change.duration)
    end
  end
  
  describe '#remap' do
    before :all do
      @c2 = @change.remap(@base, @base => 3, (@base + @change.duration) => 5)
    end
    
    it 'should return a new Gradual' do
      @c2.should be_a(Change::Gradual)
      @c2.should_not be(@change)
    end
    
    it 'should keep end value, and change duration based on given offset map' do
      @c2.end_value.should eq(@change.end_value)
      @c2.duration.should eq(2)
    end
  end
  
  describe '#to_transition' do
    context 'linear transition' do
      before :all do
        @change = Change::Gradual.linear(130,20)
        @offset = 3
        @start_value = 50
        @func = @change.to_transition(@offset, @start_value)
      end
      
      it 'should return a linear transition' do
        @func.should be_a Transition::Linear
      end
      
      it 'should make function that evaluates to start_value before start offset' do
        @func.at(@offset-1).should eq(@start_value)
      end

      it 'should make function that evaluates to start_value at start offset' do
        @func.at(@offset).should eq(@start_value)
      end
      
      it 'should make function that evaluates to end_value at start offset + duration' do
        @func.at(@offset + @change.duration).should eq(@change.end_value)
      end
      
      it 'should make function that evaluates to 1/2 between start/end value at 1/2 between start/end offset' do
        tgt = (@change.end_value + @start_value) / 2.0
        @func.at(@offset + @change.duration/2.0).should eq(tgt)
      end
      
      it 'should make function that evaluates to end value after change has elapsed' do
        @func.at(@offset + @change.duration + 1).should eq(@change.end_value)
      end
    end
    
    context 'sigmoid transition' do
      before :all do
        @change = Change::Gradual.sigmoid(130,20)
        @offset = 3
        @start_value = 50
        @func = @change.to_transition(@offset, @start_value)
      end
      
      it 'should return a sigmoid function' do
        @func.should be_a Transition::Sigmoid
      end

      it 'should make function that evaluates to start_value before start offset' do
        @func.at(@offset-1).should eq(@start_value)
      end
      
      it 'should make function that evaluates to start_value at start offset' do
        @func.at(@offset).should eq(@start_value)
      end
      
      it 'should make function that evaluates to end_value at start offset + duration' do
        @func.at(@offset + @change.duration).should eq(@change.end_value)
      end
      
      it 'should make function that evaluates to 1/2 between start/end value at 1/2 between start/end offset' do
        tgt = (@change.end_value + @start_value) / 2.0
        @func.at(@offset + @change.duration/2.0).should eq(tgt)
      end
      
      it 'should make function that evaluates to end value after change has elapsed' do
        @func.at(@offset + @change.duration + 1).should eq(@change.end_value)
      end
    end
  end
end

describe Change::Gradual::Trimmed do
  before :all do
    @change = Change::Gradual.linear(100,1.5.to_r).to_trimmed(0.5.to_r,0.5.to_r)
    @base = 25.5.to_r
  end
  
  describe '#offsets' do
    before :all do
      @offsets = @change.offsets(@base)
    end
    
    it 'should return array with 2 elements' do
      @offsets.size.should eq(4)
    end
    
    it 'should include the given base offset' do
      @offsets.should include(@base)
    end
    
    it 'should include the base offset - preceding' do
      @offsets.should include(@base - @change.preceding)
    end
    
    it 'should include the base offset + remaining' do
      @offsets.should include(@base + @change.remaining)
    end
    
    it 'should include the base offset - preceding + duration' do
      @offsets.should include(@base - @change.preceding + @change.duration)
    end
  end
  
  describe '#remap' do
    before :all do
      @offsets = { @base => 3, (@base - @change.preceding) => 0,
        (@base + @change.remaining) => 5, (@base - @change.preceding + @change.duration) => 7 }
      @c2 = @change.remap(@base, @offsets)
    end
    
    it 'should return a new Gradual::Trimmed' do
      @c2.should be_a(Change::Gradual::Trimmed)
      @c2.should_not be(@change)
    end
    
    it 'should keep end value, and change duration based on given offset map' do
      @c2.end_value.should eq(@change.end_value)
      @c2.duration.should eq(7)
      @c2.preceding.should eq(3)
      @c2.remaining.should eq(2)
    end
  end
  
  describe '#to_transition' do
    Change::Gradual::TRANSITIONS.each do |transition|
      context "#{transition} transition" do
        before :all do
          untrimmed = Change::Gradual.new(130,20, transition)
          untrimmed_offset = 0
          untrimmed_start_val = 50
          @untrimmed_trans = untrimmed.to_transition(untrimmed_offset, untrimmed_start_val)
          
          trimmed = untrimmed.trim(5,3)
          trimmed_offset = untrimmed_offset + trimmed.preceding
          trimmed_start_val = @untrimmed_trans.at(trimmed_offset)
          @trimmed_trans = trimmed.to_transition(trimmed_offset, trimmed_start_val)
          
          @xrange = trimmed_offset..(trimmed_offset + trimmed.remaining)
          srate = 50
        end
        
        it 'should produce function that stays at start value before offset' do
          @trimmed_trans.at(@xrange.first - 1).should eq(@trimmed_trans.at(@xrange.first))
        end
        
        it 'should produce function that stays at end value after transition' do
          @trimmed_trans.at(@xrange.last + 1).should eq(@trimmed_trans.at(@xrange.last))
        end
        
        it 'should produce function that samples same as equivalent untrimmed' do
          srate = 50
          @trimmed_trans.sample(@xrange, srate).should eq(@untrimmed_trans.sample(@xrange, srate))
        end
      end
    end
  end
end
