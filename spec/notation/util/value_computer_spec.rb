require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ValueComputer do
  describe '#at' do
    before :all do
      @immed_change = Change::Immediate.new(0.6)
      @lin_change = Change::Gradual.linear(0.6, 1.0)
      @sigm_change = Change::Gradual.sigmoid(0.6, 1.0)
    end
    
    context "constant value" do
      before :each do
        @comp = ValueComputer.new 0.5
      end
      
      it "should always return default value if no changes are given" do
        [ValueComputer::DOMAIN_MIN, -1000, 0, 1, 5, 100, 10000].each do |offset|
          @comp.at(offset).should eq(0.5)
        end
      end
    end
    
    context "one change, no transition" do
      before :each do
        @comp = ValueComputer.new 0.5, 1.0 => @immed_change
      end
      
      it "should be the default value just before the first change" do
        @comp.at(0.999).should eq(0.5)
      end
          
      it "should transition to the second value immediately" do
        @comp.at(1.0).should eq(0.6)
      end

      it "should be the first value for all time before" do
        @comp.at(ValueComputer::DOMAIN_MIN).should eq(0.5)
      end
      
      it "should be at the second value for all time after" do
        @comp.at(100_000).should eq(0.6)
      end
    end
    
    context "one change, linear transition" do
      before :each do
        @comp = ValueComputer.new 0.2, 1.0 => @lin_change
      end
      
      it "should be the first (starting) value just before the second value" do
        @comp.at(0.999).should eq(0.2)
      end
          
      it "should be the first (starting) value exactly at the second value" do
        @comp.at(1.0).should eq(0.2)
      end
    
      it "should be 1/4 to the second value after 1/4 transition duration has elapsed" do
        @comp.at(Rational(5,4).to_f).should eq(0.3)
      end
    
      it "should be 1/2 to the second value after 1/2 transition duration has elapsed" do
        @comp.at(Rational(6,4).to_f).should eq(0.4)
      end
    
      it "should be 3/4 to the second value after 3/4 transition duration has elapsed" do
        @comp.at(Rational(7,4).to_f).should eq(0.5)
      end
    
      it "should be at the second value after transition duration has elapsed" do
        @comp.at(Rational(8,4).to_f).should eq(0.6)
      end
    end

    context "one change, sigmoid transition" do
      before :each do
        @comp = ValueComputer.new 0.2, 1.0 => @sigm_change
      end
      
      it "should be the first (starting) value just before the second value" do
        @comp.at(0.999).should eq(0.2)
      end
          
      it "should be the first (starting) value exactly at the second value" do
        @comp.at(1.0).should eq(0.2)
      end
    
      it "should be 1/2 to the second value after 1/2 transition duration has elapsed" do
        @comp.at(1.5).should be_within(1e-5).of(0.4)
      end
    
      it "should be at the second value exactly where transition duration has elapsed" do
        @comp.at(2).should eq(0.6)
      end
      
      it "should be at the second value just after transition duration has elapsed" do
        @comp.at(2.001).should eq(0.6)
      end      
    end
  end
end

