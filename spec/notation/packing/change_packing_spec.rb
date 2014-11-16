require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  describe '#pack' do
    before :all do
      @c = Change::Immediate.new(0.5)
      @a = @c.pack
    end
    
    it 'should return an Array' do
      @a.should be_a Array
    end
    
    it 'should return an Array of size 1' do
      @a.size.should eq 1
    end
    
    it 'should put the change value at index 0' do
      @a[0].should eq @c.value
    end
  end
end

describe Change::Gradual do
  describe '#pack' do
    before :all do
      @c = Change::Gradual.new(0.3,1.5)
      @a = @c.pack
    end
    
    it 'should return an Array' do
      @a.should be_a Array
    end
    
    it 'should return an Array of size 2' do
      @a.size.should eq 2
    end
    
    it 'should put the change value at index 0' do
      @a[0].should eq @c.value
    end
    
    it 'should put the duration at index 1' do
      @a[1].should eq @c.duration
    end
  end
end

describe Change::Partial do
  describe '#pack' do
    before :all do
      @c = Change::Partial.new(0.25,0.1,0.5,0.15)
      @a = @c.pack
    end
    
    it 'should return an Array' do
      @a.should be_a Array
    end
    
    it 'should return an Array of size 4' do
      @a.size.should eq 4
    end
    
    it 'should put the change value at index 0' do
      @a[0].should eq @c.value
    end
    
    it 'should put the elapsed at index 1' do
      @a[1].should eq @c.elapsed
    end
    
    it 'should put the impending at index 2' do
      @a[2].should eq @c.impending
    end
    
    it 'should put the remaining dur at index 3' do
      @a[3].should eq @c.remaining
    end
  end
end

describe Change do
  describe '.unpack' do
    context 'given a packed immediate change' do
      before :all do
        @c = Change::Immediate.new(0.5)
        @a = @c.pack
        @c2 = Change.unpack(@a)
      end
      
      it 'should return a Change::Immediate' do
        @c2.should be_a Change::Immediate
      end
      
      it 'should successfully unpack the change value' do
        @c2.value.should eq @c.value
      end
      
      it 'should successfully unpack the change duration' do
        @c2.duration.should eq @c.duration
      end
    end
    
    context 'given a packed gradual change' do
      before :all do
        @c = Change::Gradual.new(0.3,1.5)
        @a = @c.pack
        @c2 = Change.unpack(@a)
      end
      
      it 'should return a Change::Gradual' do
        @c2.should be_a Change::Gradual
      end
      
      it 'should successfully unpack the change value' do
        @c2.value.should eq @c.value
      end
      
      it 'should successfully unpack the change duration' do
        @c2.duration.should eq @c.duration
      end
    end
    
    context 'given a packed partial change' do
      before :all do
        @c = Change::Partial.new(0.25,0.1,0.5,0.15)
        @a = @c.pack
        @c2 = Change.unpack(@a)
      end
      
      it 'should return a Change::Partial' do
        @c2.should be_a Change::Partial
      end
      
      it 'should successfully unpack the change value' do
        @c2.value.should eq @c.value
      end
      
      it 'should successfully unpack the change elapsed' do
        @c2.elapsed.should eq @c.elapsed
      end

      it 'should successfully unpack the change impending' do
        @c2.impending.should eq @c.impending
      end
      
      it 'should successfully unpack the change remaining' do
        @c2.remaining.should eq @c.remaining
      end
    end
  end
end
