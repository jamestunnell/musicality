require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

[
  [Link::Glissando, Link::Portamento, LINK_SYMBOLS[Link::Glissando]],
  [Link::Portamento, Link::Glissando, LINK_SYMBOLS[Link::Portamento]],
].each do |klass,klass2,link_symbol|
  describe klass do
    before :all do
      @tgt_pitch = C2
      @obj = klass.new(@tgt_pitch)
    end

    describe '#initialize' do
      it 'should assign the given pitch to :target_pitch' do
        expect(@obj.target_pitch).to eq(@tgt_pitch)
      end
    end

    describe '#==' do
      it 'should return true if two links have the same target pitch' do
        expect(@obj).to eq(klass.new(@tgt_pitch))
      end

      it 'should return false if two links do not have the same target pitch' do
        expect(@obj).to_not eq(klass.new(@tgt_pitch.transpose(1)))
      end

      it 'should return false if the link type is different' do
        expect(@obj).to_not eq(klass2.new(@tgt_pitch))
      end
    end

    describe '#clone' do
      it 'should return a link equal to original' do
        expect(@obj.clone).to eq @obj
      end
    end

    describe '#to_yaml' do
      it 'should produce YAML that can be loaded' do
        expect(YAML.load(@obj.to_yaml)).to eq @obj
      end
    end

    describe '#pack' do
      it 'should produce a Hash' do
        expect(@obj.pack).to be_a Hash
      end
    end

    describe 'unpack' do
      it 'should produce a Link object equal the original' do
        obj2 = @obj.class.unpack @obj.pack
        expect(obj2).to be_a @obj.class
        expect(obj2).to eq @obj
      end
    end

    describe '#to_s' do
      it 'should produce string that include link char and target pitch str' do
        expect(@obj.to_s).to eq(link_symbol + @tgt_pitch.to_s)
      end
    end
  end
end

describe Link::Tie do
  before :all do
    @obj = Link::Tie.new
  end

  describe '#==' do
    it 'should return true if another Tie object is given' do
      expect(@obj).to eq(Link::Tie.new)
    end

    it 'should return false if an object of another class is given' do
      expect(@obj).to_not eq(5)
    end
  end

  describe '#clone' do
    it 'should return a link equal to original' do
      expect(@obj.clone).to eq @obj
    end
  end

  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      expect(YAML.load(@obj.to_yaml)).to eq @obj
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      expect(@obj.pack).to be_a Hash
    end
  end

  describe 'unpack' do
    it 'should produce a Link object equal the original' do
      obj2 = @obj.class.unpack @obj.pack
      expect(obj2).to be_a @obj.class
      expect(obj2).to eq @obj
    end
  end

  describe '#to_s' do
    it "should return #{LINK_SYMBOLS[Link::Tie]}" do
      expect(@obj.to_s).to eq(LINK_SYMBOLS[Link::Tie])
    end
  end
end
