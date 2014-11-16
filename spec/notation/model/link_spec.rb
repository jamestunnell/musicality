require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

{
  Link::Glissando => Link::Portamento,
  Link::Portamento => Link::Glissando,
  Link::Slur => Link::Legato,
  Link::Legato => Link::Slur
}.each do |klass,klass2|
  describe klass do
    describe '#initialize' do
      it 'should assign the given pitch to :target_pitch' do
        klass.new(C2).target_pitch.should eq(C2)
      end
    end
    
    describe '#==' do
      it 'should return true if two links have the same target pitch' do
        klass.new(C2).should eq(klass.new(C2))
      end
      
      it 'should return false if two links do not have the same target pitch' do
        klass.new(C2).should_not eq(klass.new(F5))
      end
      
      it 'should return false if the link type is different' do
        klass.new(C2).should_not eq(klass2.new(C2))
      end
    end
    
    describe '#clone' do
      it 'should return a link equal to original' do
        l = klass.new(C4)
        l.clone.should eq l
      end
    end
    
    describe '#to_yaml' do
      it 'should produce YAML that can be loaded' do
        l = klass.new(C5)
        YAML.load(l.to_yaml).should eq l
      end
    end
    
    describe '#to_s' do
      it 'should produce string that include link char and target pitch str' do
        l = klass.new(C3)
        l.to_s.should eq(l.link_char + "C3")
      end
    end
  end
end

describe Link::Tie do
  describe '#==' do
    it 'should return true if another Tie object is given' do
      Link::Tie.new.should eq(Link::Tie.new)
    end
    
    it 'should return false if a non-Tie object is given' do
      Link::Tie.new.should_not eq(Link::Portamento.new(C2))
    end
  end
  
  describe '#clone' do
    it 'should return a link equal to original' do
      l = Link::Tie.new
      l.clone.should eq l
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      l = Link::Tie.new
      YAML.load(l.to_yaml).should eq l
    end
  end
  
  describe '#to_s' do
    it 'should return =' do
      Link::Tie.new.to_s.should eq("=")
    end
  end
end
