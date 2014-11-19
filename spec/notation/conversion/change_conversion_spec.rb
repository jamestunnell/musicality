require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  describe '#offsets' do
    it 'should return array with just the given base offset' do
      c = Change::Immediate.new(12)
      c.offsets(44).should eq([44])
    end
  end
end

describe Change::Gradual do
  describe '#offsets' do
    before :all do
      @change = Change::Gradual.new(100,1.5,0.5,0.25)
      @base = 25.5
      @offsets = @change.offsets(@base)
    end
    
    it 'should return array with 4 elements' do
      @offsets.size.should eq(4)
    end
    
    it 'should include the given base offset' do
      @offsets.should include(@base)
    end
    
    it 'should include the base offset - elapsed' do
      @offsets.should include(@base - @change.elapsed)
    end
    
    it 'should include the base offset + impending' do
      @offsets.should include(@base + @change.impending)
    end
    
    it 'should include the base offset + impending + remaining' do
      @offsets.should include(@base + @change.impending + @change.remaining)
    end
  end
end
