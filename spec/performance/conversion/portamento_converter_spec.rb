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
            expect(pitches.first).to eq(start)
          end

          it 'should space pitches using given cent step size' do
            (1...pitches.size).each do |i|
              diff = pitches[i].total_cents - pitches[i-1].total_cents
              expect(diff).to eq(step_size)
            end
          end

          it 'should end where one more step would be >= target pitch' do
            diff = finish.total_cents - pitches.last.total_cents
            expect(diff).to be <= step_size
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
            expect(pitches.first).to eq(start)
          end

          it 'should space pitches using negative of given cent step size' do
            (1...pitches.size).each do |i|
              diff = pitches[i-1].total_cents - pitches[i].total_cents
              expect(diff).to eq(step_size)
            end
          end

          it 'should end where one more step would be <= target pitch' do
            diff = pitches.last.total_cents - finish.total_cents
            expect(diff).to be <= step_size
          end
        end
      end
    end
  end

  describe '.portamento_elements' do
    before :all do
      @dur = Rational(3,2)
      @att = Attack::NONE
      @els = PortamentoConverter.portamento_elements(C4,F4,25,@dur,@att)
    end

    it 'should return an array of NoteSequence::Element objects' do
      @els.each {|el| expect(el).to be_a NoteSequence::Element }
    end

    it 'should split up duration among elements' do
      sum = @els.map {|el| el.duration }.inject(0,:+)
      expect(sum).to eq(@dur)
    end

    it 'should set attack as given for first element only and set others to NONE' do
      els = PortamentoConverter.portamento_elements(C4,D4,10,1,Attack::ACCENT)
      expect(els.first.attack).to eq(Attack::ACCENT)
      els[1..-1].each {|el| expect(el.attack).to eq(Attack::NONE) }
      els = PortamentoConverter.portamento_elements(C4,D4,10,1,Attack::TENUTO)
      expect(els.first.attack).to eq(Attack::TENUTO)
      els[1..-1].each {|el| expect(el.attack).to eq(Attack::NONE) }
    end
  end
end
