require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

[
  [Link::Glissando, Link::Portamento, LINK_SYMBOLS[Links::GLISSANDO]],
  [Link::Portamento, Link::Glissando, LINK_SYMBOLS[Links::PORTAMENTO]],
].each do |klass,klass2,link_symbol|
  describe klass do
    before :all do
      @tgt_pitch = C2
      @obj = klass.new(@tgt_pitch)
    end

    describe '#initialize' do
      it 'should assign the given pitch to :target_pitch' do
        @obj.target_pitch.should eq(@tgt_pitch)
      end
    end
    
    describe '#==' do
      it 'should return true if two links have the same target pitch' do
        @obj.should eq(klass.new(@tgt_pitch))
      end
      
      it 'should return false if two links do not have the same target pitch' do
        @obj.should_not eq(klass.new(@tgt_pitch.transpose(1)))
      end
      
      it 'should return false if the link type is different' do
        @obj.should_not eq(klass2.new(@tgt_pitch))
      end
    end
    
    describe '#clone' do
      it 'should return a link equal to original' do
        @obj.clone.should eq @obj
      end
    end
    
    describe '#to_yaml' do
      it 'should produce YAML that can be loaded' do
        YAML.load(@obj.to_yaml).should eq @obj
      end
    end
    
    describe '#to_s' do
      it 'should produce string that include link char and target pitch str' do
        @obj.to_s.should eq(link_symbol + @tgt_pitch.to_s)
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
      @obj.should eq(Link::Tie.new)
    end
    
    it 'should return false if an object of another class is given' do
      @obj.should_not eq(5)
    end
  end
  
  describe '#clone' do
    it 'should return a link equal to original' do
      @obj.clone.should eq @obj
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      YAML.load(@obj.to_yaml).should eq @obj
    end
  end
  
  describe '#to_s' do
    it "should return #{LINK_SYMBOLS[Links::TIE]}" do
      @obj.to_s.should eq(LINK_SYMBOLS[Links::TIE])
    end
  end
end
