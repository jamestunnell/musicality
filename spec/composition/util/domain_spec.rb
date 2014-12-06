require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Domain do
  describe '#initialize' do
    context 'given a decreasing left-right pair' do
      it 'should raise DecreasingError' do
        expect { Domain.new(3,2,false,false) }.to raise_error(DecreasingError)
      end
    end
    
    context 'given an equal or increasing left-right pair' do
      it 'should not raise error' do
        expect { Domain.new(3,3,false,false) }.not_to raise_error
        expect { Domain.new(3,4,false,false) }.not_to raise_error
      end
    end
  end
  
  describe '#include_left?' do
    it 'should return the value given to #initialize' do
      Domain.new(0,4,true,false).include_left?.should eq true
      Domain.new(0,4,false,false).include_left?.should eq false
    end
  end
  
  describe '#include_right?' do
    it 'should return the value given to #initialize' do
      Domain.new(0,4,false,true).include_right?.should eq true
      Domain.new(0,4,false,false).include_right?.should eq false
    end
  end
  
  describe '#exclude? and #include?' do
    context 'given value that should be excluded' do
      it '#exclude? should return true and #include? should return false' do
        { Domain.new(3,5,true,true) => [-10,0,2,6,10],
          Domain.new(-20,200,false,true) => [-21,-20,201,2000],
          Domain.new(50,54,true,false) => [49,54,55]
        }.each do |domain, excluded|
          excluded.each do |x|
            domain.exclude?(x).should eq true
            domain.include?(x).should eq false
          end
        end
      end
    end
    
    context 'given value that should be included' do
      it '#exclude? should return false and #include? should return true' do
        { Domain.new(3,5,true,true) => [3,4,5],
          Domain.new(-20,200,false,true) => [-19,100,200],
          Domain.new(50,54,true,false) => [50,51,52,53]
        }.each do |domain, not_excluded|
          not_excluded.each do |x|
            domain.exclude?(x).should eq false
            domain.include?(x).should eq true
          end
        end
      end
    end
  end
  
  describe '#check' do
    context 'given value that is excluded in domain' do
      it 'should raise DomainError' do
        expect { Domain.new(3,20,true,true).check(2) }.to raise_error(DomainError)
      end
    end
    
    context 'given value that is included in domain' do
      it 'should not raise error' do
        expect { Domain.new(3,20,true,true).check(3) }.to_not raise_error
      end
    end
  end
end
