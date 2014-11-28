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
end
