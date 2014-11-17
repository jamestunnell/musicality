require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe PortamentoConverter do
  describe '.portamento_pitches' do
    context 'start pitch <= target_pitch' do
      [
        [C4,E4,10],
        [D2,G3,11],
        [C4.transpose(0.5), A4.transpose(-0.3), 12],
        [D5,D5,7],
        [D5,D5.transpose(0.06),7],
        [D5,D5.transpose(0.07),7],
        [D5,D5.transpose(0.08),7],
      ].each do |start,finish,step_size|
        context "start at #{start.to_s}, end at #{finish.to_s}" do
          pitches = PortamentoConverter.portamento_pitches(start,finish,step_size)
          
          it 'should begin at start pitch' do
            pitches.first.should eq(start)
          end
          
          it 'should space pitches using given cent step size' do
            (1...pitches.size).each do |i|
              diff = pitches[i].total_cents - pitches[i-1].total_cents
              diff.should eq(step_size)
            end
          end
          
          it 'should end where one more step would be >= target pitch' do
            diff = finish.total_cents - pitches.last.total_cents
            diff.should be <= step_size
          end
        end
      end
    end

    context 'start pitch > target_pitch' do
      [
        [E4,C4,10],
        [G3,D2,11],
        [A4,Bb3,12],
        [A4.transpose(-0.33),Bb3.transpose(0.11),13],
        [Bb3.transpose(0.64),Bb3.transpose(0.54),14],
      ].each do |start,finish,step_size|
        context "start at #{start.to_s}, end at #{finish.to_s}" do
          pitches = PortamentoConverter.portamento_pitches(start,finish,step_size)
          
          it 'should begin at start pitch' do
            pitches.first.should eq(start)
          end
          
          it 'should space pitches using negative of given cent step size' do
            (1...pitches.size).each do |i|
              diff = pitches[i-1].total_cents - pitches[i].total_cents
              diff.should eq(step_size)
            end
          end
          
          it 'should end where one more step would be <= target pitch' do
            diff = pitches.last.total_cents - finish.total_cents
            diff.should be <= step_size
          end
        end
      end
    end
  end
  
  describe '.portamento_elements' do
    before :all do
      @dur = Rational(3,2)
      @acc = false
      @els = PortamentoConverter.portamento_elements(C4,F4,25,@dur,@acc)
    end
    
    it 'should return an array of SlurredElement objects' do
      @els.each {|el| el.should be_a SlurredElement }
    end
    
    it 'should split up duration among elements' do
      sum = @els.map {|el| el.duration }.inject(0,:+)
      sum.should eq(@dur)
    end
    
    it 'should set accented as given' do
      els = PortamentoConverter.portamento_elements(C4,D4,10,1,false)
      els.each {|el| el.accented.should eq(false) }
      els = PortamentoConverter.portamento_elements(C4,D4,10,1,true)
      els.each {|el| el.accented.should eq(true) }
    end
  end
end