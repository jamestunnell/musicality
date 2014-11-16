require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Program do
  before :all do
    @p = Program.new([0...5,3.0...6.5,("1/2".to_r)...("3/2".to_r)])
    @a = @p.pack
    @p2 = Program.unpack(@a)
  end

  describe '#pack' do    
    it 'should return an Array' do
      @a.should be_a Array
    end
    
    it 'should return an array with same size as # of segments' do
      @a.size.should eq @p.segments.size
    end
    
    it 'should return an array of strings' do
      @a.each {|x| x.should be_a String }
    end
  end

  describe '#unpack' do
    it 'should return a Program' do
      @p2.should be_a Program
    end
    
    it 'should successfully unpack program segments' do
      @p2.segments.should eq @p.segments
    end
  end
end
