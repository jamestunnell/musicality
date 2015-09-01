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
    
    it 'should have "type" and "end_value" keys' do
      @p.should have_key("type")
      @p.should have_key("end_value")
    end
    
    it 'should assign "Immediate" to "type" key' do
      @p["type"].should eq("Immediate")
    end
    
    it 'should assign end_value to "end_value" key' do
      @p["end_value"].should eq(@c.end_value)
    end
    
    context 'given block' do
      it 'should yield the end value and assign result in packing' do
        p = @c.pack {|v| v.to_s }
        p["end_value"].should be_a String
        p["end_value"].to_f.should eq(@c.end_value)
      end
    end
  end
end

describe Change::Gradual do
  describe '#pack' do
    before :all do
      @c = Change::Gradual.linear(200,2.5)
      @p = @c.pack
    end
    
    it 'should return a Hash' do
      @p.should be_a Hash
    end
    
    it 'should have "type", "end_value", "duration", "transition", and keys' do
      @p.keys.sort.should eq(["duration","end_value","transition","type"])
    end
    
    it 'should assign "Gradual" to "type" key' do
      @p["type"].should eq("Gradual")
    end
    
    it 'should assign end_value to "end_value" key' do
      @p["end_value"].should eq(@c.end_value)
    end
    
    it 'should assign duration to "duration" key' do
      @p["duration"].should eq(@c.duration)
    end
    
    it 'should assign start value to "start_value" key' do
      @p["start_value"].should eq(@c.start_value)
    end

    it 'should assign transition to "transition" key' do
      @p["transition"].should eq(@c.transition)
    end
    
    context 'given block' do
      it 'should yield the end value and assign result in packing' do
        p = @c.pack {|v| v.to_s }
        p["end_value"].should be_a String
        p["end_value"].to_f.should eq(@c.end_value)
      end
    end
    
    context 'given start value' do
      it 'should assign start_value to "start_value" ' do
        c = Change::Gradual.linear(200,2.5,start_value: 20)
        p = c.pack
        p.should have_key("start_value")
        p["start_value"].should eq(c.start_value)
      end
      
      context 'given block' do
        it 'should yield start_value and then end_value to block' do
          c = Change::Gradual.linear(200,2.5,start_value: 20)
          p = c.pack {|v| v.to_s }
          p["start_value"].should be_a String
          p["start_value"].to_f.should eq(c.start_value)
          p["end_value"].should be_a String
          p["end_value"].to_f.should eq(c.end_value)
        end
      end
    end
  end
end

describe Change::Gradual::Trimmed do
  describe '#pack' do
    before :all do
      @c = Change::Gradual::Trimmed.linear(200,2.5,preceding:1,remaining:0.5)
      @p = @c.pack
    end
    
    it 'should return a Hash' do
      @p.should be_a Hash
    end
    
    it 'should have "type", "end_value", "duration", "transition", "preceding", "remaining" keys' do
      @p.keys.sort.should eq(["duration","end_value","preceding","remaining","transition","type"])
    end
    
    it 'should assign "Gradual::Trimmed" to "type" key' do
      @p["type"].should eq("Gradual::Trimmed")
    end
    
    it 'should assign end_value to "end_value" key' do
      @p["end_value"].should eq(@c.end_value)
    end
    
    it 'should assign duration to "duration" key' do
      @p["duration"].should eq(@c.duration)
    end
    
    it 'should assign transition to "transition" key' do
      @p["transition"].should eq(@c.transition)
    end

    it 'should assign preceding to "preceding" key' do
      @p["preceding"].should eq(@c.preceding)
    end
    
    it 'should assign remaining to "remaining" key' do
      @p["remaining"].should eq(@c.remaining)
    end
    
    context 'given block' do
      it 'should yield the end value and assign result in packing' do
        p = @c.pack {|v| v.to_s }
        p["end_value"].should be_a String
        p["end_value"].to_f.should eq(@c.end_value)
      end
    end

    context 'given start value' do
      it 'should assign start_value to "start_value" ' do
        c = Change::Gradual.linear(200,2.5,start_value: 20).trim(0.5,0.5)
        p = c.pack
        p.should have_key("start_value")
        p["start_value"].should eq(c.start_value)
      end
      
      context 'given block' do
        it 'should yield start_value and then end_value to block' do
          c = Change::Gradual.linear(200,2.5,start_value: 20).trim(0.5,0.5)
          p = c.pack {|v| v.to_s }
          p["start_value"].should be_a String
          p["start_value"].to_f.should eq(c.start_value)
          p["end_value"].should be_a String
          p["end_value"].to_f.should eq(c.end_value)
        end
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
      
      it 'should successfully unpack the change end_value' do
        @c2.end_value.should eq @c.end_value
      end
      
      context 'pack/unpack using block' do
        it 'should use given block to convert end_value' do
          c = Change::Immediate.new(0.5)
          h = c.pack{|v| v.to_s}
          c2 = Change.unpack(h)
          c2.end_value.should be_a String
          c3 = Change.unpack(h){|v| v.to_f}
          c3.end_value.should be_a Float
        end
      end
    end
    
    context 'given a packed gradual change' do
      before :all do
        @c = Change::Gradual.sigmoid(0.3,1.5)
        @a = @c.pack
        @c2 = Change.unpack(@a)
      end
      
      it 'should return a Change::Gradual' do
        @c2.should be_a Change::Gradual
      end
      
      it 'should unpack the end_value' do
        @c2.end_value.should eq @c.end_value
      end
      
      it 'should unpack the change duration' do
        @c2.duration.should eq @c.duration
      end

      it 'should unpack the change transition' do
        @c2.transition.should eq @c.transition
      end
      
      it 'should unpack the change start_value' do
        @c2.start_value.should eq @c.start_value
      end
      
      context 'pack/unpack using block' do
        it 'should use given block to convert end_value' do
          c = Change::Gradual.linear(0.5,2)
          h = c.pack{|v| v.to_s}
          c2 = Change.unpack(h)
          c2.end_value.should be_a String
          c3 = Change.unpack(h){|v| v.to_f}
          c3.end_value.should be_a Float
        end
        
        context 'when change start_value is not nil' do
          it 'should use given :with method to convert start_value' do
            c = Change::Gradual.linear(0.5,2,start_value: 0.1)
            h = c.pack{|v| v.to_s}
            c2 = Change.unpack(h)
            c2.start_value.should be_a String
            c3 = Change.unpack(h){|v| v.to_f}
            c3.start_value.should be_a Float
          end
        end
      end
    end
    
    context 'given a packed gradual (trimmed) change' do
      before :all do
        @c = Change::Gradual::Trimmed.sigmoid(0.3,1.5,preceding:0.1,remaining:0.1)
        @a = @c.pack
        @c2 = Change.unpack(@a)
      end
      
      it 'should return a Change::Gradual' do
        @c2.should be_a Change::Gradual
      end
      
      it 'should successfully unpack the end_value' do
        @c2.end_value.should eq @c.end_value
      end
      
      it 'should successfully unpack the change duration' do
        @c2.duration.should eq @c.duration
      end

      it 'should successfully unpack the change transition' do
        @c2.transition.should eq @c.transition
      end
      
      it 'should unpack the change start_value' do
        @c2.start_value.should eq @c.start_value
      end
      
      it 'should successfully unpack the change preceding' do
        @c2.preceding.should eq @c.preceding
      end
      
      it 'should successfully unpack the change remaining' do
        @c2.remaining.should eq @c.remaining
      end
      
      context 'pack/unpack using block' do
        it 'should use given block to convert end_value' do
          c = Change::Gradual.linear(0.5,2).trim(0.4,0.3)
          h = c.pack{|v| v.to_s}
          c2 = Change.unpack(h)
          c2.end_value.should be_a String
          c3 = Change.unpack(h){|v| v.to_f}
          c3.end_value.should be_a Float
        end
        
        context 'when change start_value is not nil' do
          it 'should use given :with method to convert start_value' do
            c = Change::Gradual.linear(0.5,2,start_value: 0.1).trim(0.4,0.3)
            h = c.pack{|v| v.to_s}
            c2 = Change.unpack(h)
            c2.start_value.should be_a String
            c3 = Change.unpack(h){|v| v.to_f}
            c3.start_value.should be_a Float
          end
        end
      end
    end    
  end
end
