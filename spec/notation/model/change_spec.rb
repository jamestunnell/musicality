require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  context '#initialize' do
    it 'should set value to given' do
      Change::Immediate.new(5).value.should eq 5
    end
    
    it 'should set duration to 0' do
      Change::Immediate.new(5).duration.should eq 0
    end
  end
    
  describe '==' do
    it 'should return true if two immediate changes have the same value' do
      Change::Immediate.new(5).should eq(Change::Immediate.new(5))
    end
    
    it 'should return false if two immediate changes do not have the same value' do
      Change::Immediate.new(5).should_not eq(Change::Immediate.new(4))
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      c = Change::Immediate.new(4)
      YAML.load(c.to_yaml).should eq c
    end
  end
end

describe Change::Gradual do
  context '#initialize' do
    it 'should set value to given value' do
      Change::Gradual.new(5,2).value.should eq 5
    end
    
    it 'should set duration to given duration' do
      Change::Gradual.new(5,2).duration.should eq 2
    end
  end
    
  describe '==' do
    it 'should return true if two gradual changes have the same value and duration' do
      Change::Gradual.new(5,2).should eq(Change::Gradual.new(5,2))
    end
    
    it 'should return false if two gradual changes do not have the same value' do
      Change::Gradual.new(5,2).should_not eq(Change::Gradual.new(4,2))
    end
    
    it 'should return false if two gradual changes do not have the same duration' do
      Change::Gradual.new(5,2).should_not eq(Change::Gradual.new(5,1))
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      c = Change::Gradual.new(4,2)
      YAML.load(c.to_yaml).should eq c
    end
  end
end

describe Change::Gradual do
  context '.new' do
    it 'should set value to given value' do
      Change::Gradual.new(5,2).value.should eq 5
    end
    
    it 'should set duration to given duration' do
      Change::Gradual.new(5,2).duration.should eq 2
    end
  end
    
  describe '==' do
    it 'should return true if two gradual changes have the same value and duration' do
      Change::Gradual.new(5,2).should eq(Change::Gradual.new(5,2))
    end
    
    it 'should return false if two gradual changes do not have the same value' do
      Change::Gradual.new(5,2).should_not eq(Change::Gradual.new(4,2))
    end
    
    it 'should return false if two gradual changes do not have the same duration' do
      Change::Gradual.new(5,2).should_not eq(Change::Gradual.new(5,1))
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      c = Change::Gradual.new(4,2)
      YAML.load(c.to_yaml).should eq c
    end
  end
end

describe Change::Partial do
  context '#initialize' do
    it 'should set value to given value' do
      Change::Partial.new(200,5,1,2).value.should eq(200)
    end
    
    it 'should set duration to given impending duration' do
      Change::Partial.new(200,5,1,2).duration.should eq(1)
    end

    it 'should not raise error if given elapsed == 0' do
      expect { Change::Partial.new(200,0,1,2) }.to_not raise_error
    end
    
    it 'should raise NegativeError if given elapsed < 0' do
      expect { Change::Partial.new(200,-1e-15,1,2) }.to raise_error(NegativeError)
    end

    it 'should raise NonPositiveError if given impending <= 0' do
      expect { Change::Partial.new(200,5,0,1) }.to raise_error(NonPositiveError)
      expect { Change::Partial.new(200,5,-1,1) }.to raise_error(NonPositiveError)
    end

    it 'should not raise erro if given remaining == 0' do
      expect { Change::Partial.new(200,5,1,0) }.to_not raise_error
    end
    
    it 'should raise NegativeError if given remaining < 0' do
      expect { Change::Partial.new(200,5,1,-1) }.to raise_error(NegativeError)
    end
  end
end