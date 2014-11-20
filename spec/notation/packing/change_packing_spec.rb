require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  describe '#pack' do
    before :all do
      @c = Change::Immediate.new(0.5)
      @p = @c.pack
    end
    
    it 'should return a Hash' do
      @p.should be_a Hash
    end
    
    it 'should have "type" and "value" keys' do
      @p.should have_key("type")
      @p.should have_key("value")
    end
    
    it 'should assign "Immediate" to "type" key' do
      @p["type"].should eq("Immediate")
    end
    
    it 'should assign value to "value" key' do
      @p["value"].should eq(@c.value)
    end
  end
end

describe Change::Gradual do
  describe '#pack' do
    context 'in general' do
      before :all do
        @c = Change::Gradual.new(200,2.5,3.3,4.5)
        @p = @c.pack
      end
      
      it 'should return a Hash' do
        @p.should be_a Hash
      end
      
      it 'should have "type", "value", and "impending" keys' do
        @p.should have_key("type")
        @p.should have_key("value")
        @p.should have_key("impending")
      end
      
      it 'should assign "Gradual" to "type" key' do
        @p["type"].should eq("Gradual")
      end
      
      it 'should assign value to "value" key' do
        @p["value"].should eq(@c.value)
      end
      
      it 'should assign impending to "impending" key' do
        @p["impending"].should eq(@c.impending)
      end
    end
    
    context 'elapsed and remaining are 0' do
      before :all do
        @c = Change::Gradual.new(200,2.5)
        @p = @c.pack
      end
      
      it 'should *only* have "type", "value", and "impending" keys' do
        @p.keys.sort.should eq(["impending","type","value"])
      end
    end

    context 'elapsed is not 0, but remaining is 0' do
      before :all do
        @c = Change::Gradual.new(200,2.5,1.1)
        @p = @c.pack
      end
      
      it 'should *only* have "type", "value", "impending", and "elapsed" keys' do
        @p.keys.sort.should eq(["elapsed","impending","type","value"])
      end
      
      it 'should assign elapsed to "elapsed" key' do
        @p["elapsed"].should eq(@c.elapsed)
      end
    end
    
    context 'elapsed and remaining are not 0' do
      before :all do
        @c = Change::Gradual.new(200,2.5,1.1,2.2)
        @p = @c.pack
      end
      
      it 'should *only* have "type", "value", "impending", "elapsed", and "remaining" keys' do
        @p.keys.sort.should eq(["elapsed","impending","remaining","type","value"])
      end
      
      it 'should assign remaining to "remaining" key' do
        @p["remaining"].should eq(@c.remaining)
      end
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
        @c = Change::Gradual.new(0.3,1.5,1.1,0.2)
        @a = @c.pack
        @c2 = Change.unpack(@a)
      end
      
      it 'should return a Change::Gradual' do
        @c2.should be_a Change::Gradual
      end
      
      it 'should successfully unpack the change value' do
        @c2.value.should eq @c.value
      end
      
      it 'should successfully unpack the change impending (duration)' do
        @c2.impending.should eq @c.impending
      end
      
      it 'should successfully unpack the change elapsed' do
        @c2.elapsed.should eq @c.elapsed
      end

      it 'should successfully unpack the change remaining' do
        @c2.remaining.should eq @c.remaining
      end      
    end
  end
end
