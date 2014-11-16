require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Program do
  
  it "should assign the segments given during initialization" do
    segments = [ 0.0...5.0, 0.0...4.0, 5.0...10.0 ]
    program = Program.new segments
    program.segments.should eq(segments.clone)
  end
  
  describe "#include?" do
    it "should return true for any offset which would be encountered" do
      segments = [ 0.0...5.0, 0.0...4.0, 5.0...10.0 ]
      program = Program.new segments
      
      [0.0, 4.0, 5.0, 9.999].each do |offset|
        program.include?(offset).should be true
      end
    end

    it "should return false for any offset which would not be encountered" do
      segments = [ 0.0...5.0, 0.0...4.0, 5.0...10.0 ]
      program = Program.new segments
      
      [-0.000001, 10.000001].each do |offset|
        program.include?(offset).should be false
      end
    end
  end
  
  describe '#valid?' do
    context 'increasing, positive segments' do
      it 'should return true' do
        Program.new([0..2,1..2,0..4]).should be_valid
      end
    end
    
    context 'decreasing, positive segments' do
      it 'should return false' do
        Program.new([2..0,2..1,04..0]).should be_invalid
      end
    end

    context 'increasing, negative segments' do
      it 'should return false' do
        Program.new([-1..2,-2..0,-2..2]).should be_invalid
      end
    end
  end
end
