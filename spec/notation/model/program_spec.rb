require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Program do
  describe '#initialize' do
    it 'should take a variable number of arguments' do
      p = Program.new(0..3,4..5,3..4).should eq([0..3,4..5,3..4])
    end
    
    it 'should take a single array' do
      Program.new([0..3,4..5,3..4]).should eq([0..3,4..5,3..4])
    end
  end
  
  describe '#segments' do
    it 'should return array entries' do
      Program.new.segments.should be_empty
      Program.new(0..1,0..2).segments.should eq([0..1,0..2])
    end
  end
  
  describe "#include_offset?" do
    it "should return true for any offset which should be in a segment" do
      program = Program.new(0.0...5.0, 0.0...4.0, 5.0...10.0)
      [0.0, 4.0, 5.0, 9.999].each do |offset|
        program.include_offset?(offset).should be true
      end
    end

    it "should return false for any offset which would not be encountered" do
      program = Program.new(0.0...5.0, 0.0...4.0, 5.0...10.0)
      [-0.000001, 10.000001].each do |offset|
        program.include_offset?(offset).should be false
      end
    end
  end
  
  describe '#valid?' do
    context 'non-Range objects' do
      it 'should return false' do
        Program.new(1,2,3).should_not be_valid
      end
    end
    
    context 'increasing, positive segments' do
      it 'should return true' do
        Program.new(0..2,1..2,0..4).should be_valid
      end
    end
    
    context 'decreasing, positive segments' do
      it 'should return false' do
        Program.new(2..0,2..1,04..0).should be_invalid
      end
    end

    context 'increasing, negative segments' do
      it 'should return false' do
        Program.new(-1..2,-2..0,-2..2).should be_invalid
      end
    end
  end
end

describe Array do
  describe '#to_program' do
    it 'should convert the array object to a program' do
      [1,2,3,4].to_program.should be_a Program
    end
  end
end
