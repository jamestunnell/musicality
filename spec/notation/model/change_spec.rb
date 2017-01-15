require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  context '#initialize' do
    it 'should set end value to given' do
      expect(Change::Immediate.new(5).end_value).to eq 5
    end
  end

  describe '==' do
    it 'should return true if two immediate changes have the same end value' do
      expect(Change::Immediate.new(5)).to eq(Change::Immediate.new(5))
    end

    it 'should return false if two immediate changes do not have the same end value' do
      expect(Change::Immediate.new(5)).to_not eq(Change::Immediate.new(4))
    end
  end

  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      c = Change::Immediate.new(4)
      expect(YAML.load(c.to_yaml)).to eq c
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      h = Change::Immediate.new(2).pack
      expect(h).to be_a Hash
    end
  end

  describe '.unpack' do
    it 'should return a Change::Immediate equal to the original' do
      c1 = Change::Immediate.new(2)
      c2 = Change::Immediate.unpack(c1.pack)
      expect(c2).to be_a Change::Immediate
      expect(c2).to eq c1
    end
  end
end

describe Change::Gradual do
  context '#initialize' do
    it 'should set end value and duration to given values' do
      ch = Change::Gradual.new(5,2,Change::Gradual::LINEAR)
      expect(ch.end_value).to eq(5)
      expect(ch.duration).to eq(2)
    end

    it 'should set start_value to nil if not given' do
      expect(Change::Gradual.linear(5,2).start_value).to be nil
    end

    it 'should set start_value if given' do
      expect(Change::Gradual.linear(5,2, start_value: 3).start_value).to eq(3)
    end

    it 'should raise NonPositiveError if duration is <= 0' do
      expect { Change::Gradual.new(11,0,Change::Gradual::LINEAR) }.to raise_error(NonPositiveError)
      expect { Change::Gradual.new(11,-1,Change::Gradual::LINEAR) }.to raise_error(NonPositiveError)
    end
  end

  describe '#relative?' do
    context 'start_value is nil' do
      it 'should return true' do
        expect(Change::Gradual.linear(25,3).relative?).to be true
      end
    end

    context 'start_value is not nil' do
      it 'should return false' do
        expect(Change::Gradual.linear(25,3, start_value: 10).relative?).to be false
      end
    end
  end

  context '.linear' do
    before(:all){ @change = Change::Gradual.linear(55,20, start_value: 25) }

    it 'should assign end_value, duration, and start_value as normal' do
      expect(@change.end_value).to eq(55)
      expect(@change.duration).to eq(20)
      expect(@change.start_value).to eq(25)
    end

    it 'should set transition to linear' do
      expect(@change.transition).to eq(Change::Gradual::LINEAR)
    end
  end

  context '.sigmoid' do
    before(:all){ @change = Change::Gradual.sigmoid(55,20, start_value: 25) }

    it 'should assign end_value, duration, and start_value as normal' do
      expect(@change.end_value).to eq(55)
      expect(@change.duration).to eq(20)
      expect(@change.start_value).to eq(25)
    end

    it 'should set transition to SIGMOID' do
      expect(@change.transition).to eq(Change::Gradual::SIGMOID)
    end
  end

  describe '==' do
    context 'two gradual changes have the same end value, duration, and start value' do
      it 'should return true' do
        expect(Change::Gradual.linear(5,2)).to eq(Change::Gradual.linear(5,2))
        expect(Change::Gradual.linear(5,2,start_value:0)).to eq(Change::Gradual.linear(5,2,start_value:0))
      end
    end

    context 'two gradual changes do not have the same end value' do
      it 'should return false' do
        expect(Change::Gradual.linear(5,2)).to_not eq(Change::Gradual.linear(4,2))
      end
    end

    context 'two gradual changes do not have the same duration' do
      it 'should return false' do
        expect(Change::Gradual.linear(5,2)).to_not eq(Change::Gradual.linear(5,1))
      end
    end

    context 'two gradual changes do not have the start value' do
      it 'should return false' do
        expect(Change::Gradual.linear(5,2, start_value: 3)).to_not eq(Change::Gradual.linear(5,1))
      end
    end
  end

  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      c = Change::Gradual.linear(4,2)
      expect(YAML.load(c.to_yaml)).to eq c
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      h = Change::Gradual.linear(4,2).pack
      expect(h).to be_a Hash
    end
  end

  describe '.unpack' do
    it 'should return a Change::Gradual equal to the original' do
      c1 = Change::Gradual.linear(4,2)
      c2 = Change::Gradual.unpack(c1.pack)
      expect(c2).to be_a Change::Gradual
      expect(c2).to eq c1
    end
  end
end

describe Change::Gradual::Trimmed do
  it 'should be a Change::Gradual' do
    expect(Change::Gradual::Trimmed.new(35,1,Change::Gradual::LINEAR,preceding: 0, remaining: 0.5)).to be_a Change::Gradual
  end

  describe '.linear' do
    before(:all){ @change = Change::Gradual::Trimmed.linear(55,20,preceding:5,remaining:6) }

    it 'should assign end_value, duration, preceding, and remaining as normal' do
      expect(@change.end_value).to eq(55)
      expect(@change.duration).to eq(20)
      expect(@change.preceding).to eq(5)
      expect(@change.remaining).to eq(6)
    end

    it 'should set transition to linear' do
      expect(@change.transition).to eq(Change::Gradual::LINEAR)
    end
  end

  describe '.sigmoid' do
    before(:all){ @change = Change::Gradual::Trimmed.sigmoid(55,20,preceding:5,remaining:6) }

    it 'should assign end_value, duration, preceding, and remaining as normal' do
      expect(@change.end_value).to eq(55)
      expect(@change.duration).to eq(20)
      expect(@change.preceding).to eq(5)
      expect(@change.remaining).to eq(6)
    end

    it 'should set transition to SIGMOID' do
      expect(@change.transition).to eq(Change::Gradual::SIGMOID)
    end
  end

  it 'should raise NegativeError if preceding is < 0' do
    expect { Change::Gradual::Trimmed.linear(11,1,preceding: -1,remaining: 0.5) }.to raise_error(NegativeError)
  end

  it 'should raise NonPositiveError if remaining is <= 0' do
    expect { Change::Gradual::Trimmed.linear(11,3,preceding: 1,remaining: 0) }.to raise_error(NonPositiveError)
    expect { Change::Gradual::Trimmed.linear(11,3,preceding: 1,remaining: -1) }.to raise_error(NonPositiveError)
  end

  describe '#untrim' do
    before :all do
      @trimmed = Change::Gradual.linear(51,12).trim(2,2)
      @untrimmed = @trimmed.untrim
    end

    it 'should return a Change::Gradual' do
      expect(@untrimmed).to be_a Change::Gradual
    end

    it 'should keep end_value, duration, and transition' do
      expect(@untrimmed.end_value).to eq(@trimmed.end_value)
      expect(@untrimmed.duration).to eq(@trimmed.duration)
      expect(@untrimmed.transition).to eq(@trimmed.transition)
    end
  end

  describe '#trailing' do
    it 'should return the amount of transition unused at the end' do
      expect(Change::Gradual.linear(41,19).trim(4,9).trailing).to eq(9)
    end
  end

  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      c = Change::Gradual::Trimmed.linear(4,2, preceding: 1, remaining: 0.5)
      expect(YAML.load(c.to_yaml)).to eq c
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      h = Change::Gradual::Trimmed.linear(4,2, preceding: 1, remaining: 0.5).pack
      expect(h).to be_a Hash
    end
  end

  describe '.unpack' do
    it 'should return a Change::Gradual::Trimmed equal to the original' do
      c1 = Change::Gradual::Trimmed.linear(4,2, preceding: 1, remaining: 0.5)
      c2 = Change::Gradual::Trimmed.unpack(c1.pack)
      expect(c2).to be_a Change::Gradual::Trimmed
      expect(c2).to eq c1
    end
  end
end
