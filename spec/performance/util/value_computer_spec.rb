require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ValueComputer do
  describe '#value_at' do
    before :all do
      @value_change1 = Change::Immediate.new(0.6)
      @value_change2 = Change::Gradual.new(0.6, 1.0)
    end
    
    context "constant value" do
      before :each do
        @comp = ValueComputer.new 0.5
      end
      
      it "should always return default value if no changes are given" do
        [ValueComputer.domain_min, -1000, 0, 1, 5, 100, 10000, ValueComputer.domain_max].each do |offset|
          @comp.value_at(offset).should eq(0.5)
        end
      end
    end
    
    context "one change, no transition" do
      before :each do
        @comp = ValueComputer.new 0.5, 1.0 => @value_change1
      end
      
      it "should be the default value just before the first change" do
        @comp.value_at(0.999).should eq(0.5)
      end
          
      it "should transition to the second value immediately" do
        @comp.value_at(1.0).should eq(0.6)
      end

      it "should be the first value for all time before" do
        @comp.value_at(ValueComputer.domain_min).should eq(0.5)
      end
      
      it "should be at the second value for all time after" do
        @comp.value_at(ValueComputer.domain_max).should eq(0.6)
      end
    end
    
    context "one change, linear transition" do
      before :each do
        @comp = ValueComputer.new 0.2, 1.0 => @value_change2
      end
      
      it "should be the first (starting) value just before the second value" do
        @comp.value_at(0.999).should eq(0.2)
      end
          
      it "should be the first (starting) value exactly at the second value" do
        @comp.value_at(1.0).should eq(0.2)
      end
    
      it "should be 1/4 to the second value after 1/4 transition duration has elapsed" do
        @comp.value_at(Rational(5,4).to_f).should eq(0.3)
      end
    
      it "should be 1/2 to the second value after 1/2 transition duration has elapsed" do
        @comp.value_at(Rational(6,4).to_f).should eq(0.4)
      end
    
      it "should be 3/4 to the second value after 3/4 transition duration has elapsed" do
        @comp.value_at(Rational(7,4).to_f).should eq(0.5)
      end
    
      it "should be at the second value after transition duration has elapsed" do
        @comp.value_at(Rational(8,4).to_f).should eq(0.6)
      end
    end

  #  context "one change, sigmoid transition" do
  #    before :all do
  #      @cases = [
  #        { :start_value => 0, :end_value => 1, :offset => 0, :duration => 1.0, :abruptness => 0.75 },
  #        { :start_value => 0.25, :end_value => 0.75, :offset => 1.0, :duration => 2.0, :abruptness => 0.75 },
  #        { :start_value => -1.0, :end_value => 5.5, :offset => 2.4, :duration => 20, :abruptness => 0.75 },
  #        { :start_value => 10, :end_value => 100, :offset => 20, :duration => 4, :abruptness => 0.75 },
  #      ]
  #  
  #      @computers = {}
  #      @cases.each do |case_hash|
  #        start_value = case_hash[:start_value]
  #        offset = case_hash[:offset]
  #        end_value = case_hash[:end_value]
  #        duration = case_hash[:duration]
  #        #abruptness = case_hash[:abruptness]
  #        
  #        change = Change::Gradual.new(end_value, duration)
  #        @computers[case_hash] = ValueComputer.new start_value, offset => change
  #        # @computers[case_hash].plot_range(offset..(offset + duration), 0.01)
  #      end
  #    end
  #  
  #    it "should be the first (starting) value just before the value change offset" do
  #      @computers.each do |case_hash, comp|
  #        comp.value_at(case_hash[:offset] - 0.0001).should eq(case_hash[:start_value])
  #      end
  #    end
  #        
  #    it "should be very nearly the first (starting) value exactly at the value change offset" do
  #      @computers.each do |case_hash, comp|
  #        comp.value_at(case_hash[:offset]).should be_within(0.0001).of(case_hash[:start_value])
  #      end
  #    end
  #  
  #    it "should be within 1% of start/end difference away from the start value after 1/4 transition duration has elapsed" do
  #      @computers.each do |case_hash, comp|
  #        test_offset = case_hash[:offset] + (case_hash[:duration] * 0.25)
  #        start_value = case_hash[:start_value]
  #        end_value = case_hash[:end_value]
  #        tolerance = 0.01 * (end_value - start_value)
  #        comp.value_at(test_offset).should be_within(tolerance).of(start_value)
  #      end
  #    end
  #  
  #    it "should be half way to the end value after half way through transition" do
  #      @computers.each do |case_hash, comp|
  #        test_offset = case_hash[:offset] + (case_hash[:duration] * 0.5)
  #        start_value = case_hash[:start_value]
  #        expected_value = start_value + (case_hash[:end_value] - start_value) * 0.5
  #        comp.value_at(test_offset).should be_within(0.0001).of(expected_value)
  #      end
  #    end
  #  
  #    it "should be within 1% of start/end difference away from the end value after 3/4 transition duration has elapsed" do
  #      @computers.each do |case_hash, comp|
  #        test_offset = case_hash[:offset] + (case_hash[:duration] * 0.75)
  #        start_value = case_hash[:start_value]
  #        end_value = case_hash[:end_value]
  #        tolerance = 0.01 * (end_value - start_value)
  #        comp.value_at(test_offset).should be_within(tolerance).of(end_value)
  #      end
  #    end
  #  
  #    it "should be at the second value after transition duration has elapsed" do
  #      @computers.each do |case_hash, comp|
  #        comp.value_at(case_hash[:offset] + case_hash[:duration]).should eq(case_hash[:end_value])
  #      end
  #    end
  #  end
  end
end

