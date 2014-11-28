require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  context '#initialize' do
    it 'should set end value to given' do
      Change::Immediate.new(5).end_value.should eq 5
    end
  end
    
  describe '==' do
    it 'should return true if two immediate changes have the same end value' do
      Change::Immediate.new(5).should eq(Change::Immediate.new(5))
    end
    
    it 'should return false if two immediate changes do not have the same end value' do
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
    it 'should set end value and duration to given values' do
      ch = Change::Gradual.new(5,2,Change::Gradual::LINEAR)
      ch.end_value.should eq(5)
      ch.duration.should eq(2)
    end
    
    it 'should raise NonPositiveError if duration is <= 0' do
      expect { Change::Gradual.new(11,0,Change::Gradual::LINEAR) }.to raise_error(NonPositiveError)
      expect { Change::Gradual.new(11,-1,Change::Gradual::LINEAR) }.to raise_error(NonPositiveError)
    end
  end
  
  context '.linear' do
    before(:all){ @change = Change::Gradual.linear(55,20) }
    
    it 'should assign end_value and duration as normal' do
      @change.end_value.should eq(55)
      @change.duration.should eq(20)
    end
    
    it 'should set transition to linear' do
      @change.transition.should eq(Change::Gradual::LINEAR)
    end
  end

  context '.sigmoid' do
    before(:all){ @change = Change::Gradual.sigmoid(55,20) }
    
    it 'should assign end_value and duration as normal' do
      @change.end_value.should eq(55)
      @change.duration.should eq(20)
    end
    
    it 'should set transition to SIGMOID' do
      @change.transition.should eq(Change::Gradual::SIGMOID)
    end
  end
  
  describe '==' do
    it 'should return true if two gradual changes have the same value and duration' do
      Change::Gradual.linear(5,2).should eq(Change::Gradual.linear(5,2))
    end
    
    it 'should return false if two gradual changes do not have the same value' do
      Change::Gradual.linear(5,2).should_not eq(Change::Gradual.linear(4,2))
    end
    
    it 'should return false if two gradual changes do not have the same duration' do
      Change::Gradual.linear(5,2).should_not eq(Change::Gradual.linear(5,1))
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      c = Change::Gradual.linear(4,2)
      YAML.load(c.to_yaml).should eq c
    end
  end
end

describe Change::Gradual::Trimmed do
  it 'should be a Change::Gradual' do
    Change::Gradual::Trimmed.new(35,1,Change::Gradual::LINEAR,preceding: 0, remaining: 0.5).should be_a Change::Gradual
  end
  
  describe '.linear' do
    before(:all){ @change = Change::Gradual::Trimmed.linear(55,20,preceding:5,remaining:6) }
    
    it 'should assign end_value, duration, preceding, and remaining as normal' do
      @change.end_value.should eq(55)
      @change.duration.should eq(20)
      @change.preceding.should eq(5)
      @change.remaining.should eq(6)
    end
    
    it 'should set transition to linear' do
      @change.transition.should eq(Change::Gradual::LINEAR)
    end
  end
  
  describe '.sigmoid' do
    before(:all){ @change = Change::Gradual::Trimmed.sigmoid(55,20,preceding:5,remaining:6) }
    
    it 'should assign end_value, duration, preceding, and remaining as normal' do
      @change.end_value.should eq(55)
      @change.duration.should eq(20)
      @change.preceding.should eq(5)
      @change.remaining.should eq(6)
    end
    
    it 'should set transition to SIGMOID' do
      @change.transition.should eq(Change::Gradual::SIGMOID)
    end
  end
  
  it 'should raise NegativeError if preceding is < 0' do
    expect { Change::Gradual::Trimmed.linear(11,1,preceding: -1,remaining: 0.5) }.to raise_error(NegativeError)
  end

  it 'should raise NonPositiveError if remaining is <= 0' do
    expect { Change::Gradual::Trimmed.linear(11,3,preceding: 1,remaining: 0) }.to raise_error(NonPositiveError)
    expect { Change::Gradual::Trimmed.linear(11,3,preceding: 1,remaining: -1) }.to raise_error(NonPositiveError)
  end
end