require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe CompoundSequence do
  seqs = [ AddingSequence.new([1,1,0,2,-1]),
           RepeatingSequence.new([0,1,0,5,-13]) ]
  
  { :at => [0, 1, -5, 33],
    :take => [],
    :take_back => [],
    :over => []
  }.each do |method,args|
    describe "##{method}" do
      [ :+, :* ].each do |sym|
        cseq = CompoundSequence.new(sym,seqs)
        context "given #{sym} as combine method" do
          it "should inject using #{sym} to combine the separate results from calling ##{method} on each sequence" do
            args.each do |arg|
              vals = seqs.map {|s| s.send(method,arg) }
              val = vals[1..-1].inject(vals.first,sym)
              val2 = cseq.send(method,arg)
              val2.should eq(val)
            end
          end
        end
      end
    end    
  end
end
