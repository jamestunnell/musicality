require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe CompoundSequence do
  seqs = [ AddingSequence.new([1,1,0,2,-1]),
           RepeatingSequence.new([0,1,0,5,-13]) ]
  
  describe "#at" do
    context 'given single offset' do
      [ :+, :* ].each do |sym|
        cseq = CompoundSequence.new(sym,seqs)
        context "given #{sym} as combine method" do
          it "should get a value from each sequence using #at and combine using #{sym}" do
            [0, 1, -5, 33].each do |offset|
              vals = seqs.map {|s| s.at(offset) }
              val = vals[1..-1].inject(vals.first,sym)
              val2 = cseq.send(:at,offset)
              val2.should eq(val)
            end
          end
        end
      end
    end
  end
  
  { :at => [[-5,1,33,2,0,-11], [-3,-2,-1,0,1,2,-3,-2,-1]],
    :take => [ 0, 5, 10, 13 ],
    :take_back => [ 0, 2, 6, 15 ],
    :over => [ 0..12, -3...5, -10..-3 ]
  }.each do |method,args|
    describe "##{method}" do
      [ :+, :* ].each do |sym|
        cseq = CompoundSequence.new(sym,seqs)
        context "given #{sym} as combine method" do
          it "should get values from each sequence using #{method} and combine each set of values using #{sym}" do
            args.each do |arg|
              enums = seqs.map {|s| s.send(method,arg) }
              n = arg.is_a?(Fixnum) ? arg : arg.size
              vals = Array.new(n) do |i|
                _vals = enums.map {|e| e.next }
                _vals[1..-1].inject(_vals.first,sym)
              end
              vals2 = cseq.send(method,arg).to_a
              vals2.should eq(vals)
            end
          end
        end
      end
    end    
  end
end
