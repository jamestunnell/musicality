require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe GlissandoConverter do
  describe '.glissando_pitches' do
    context 'start pitch <= target pitch' do
      [
        [F3,B3],
        [C4,Gb5],
        [D2,C5],
        [F2,F2],
        [C4.transpose(0.5),D4],
        [C4.transpose(0.5),D4.transpose(0.5)],
        [C4.transpose(0.01),F5],
        [C4.transpose(-0.01),F5.transpose(-0.01)],
      ].each do |start,finish|
        context "start at #{start.to_s}, target #{finish.to_s}" do
          pitches = GlissandoConverter.glissando_pitches(start,finish)

          it 'should begin with start pitch' do
            expect(pitches.first).to eq(start)
          end

          it 'should move up to next whole (zero-cent) pitches' do
            (1...pitches.size).each do |i|
              expect(pitches[i].cent).to eq(0)
              expect(pitches[i].diff(pitches[i-1])).to be <= 1
            end
          end

          it 'should end on the whole (zero-cent) pitch below target pitch' do
            expect(pitches.last.cent).to eq(0)
            diff = finish.total_cents - pitches.last.total_cents
            expect(diff).to be <= 100
          end
        end
      end
    end

    context 'start pitch > target pitch' do
      [
        [B3,F3],
        [Gb5,C4],
        [C5,D2],
        [D4,C4.transpose(0.5)],
        [D4.transpose(0.5),C4.transpose(0.5)],
        [F5,C4.transpose(0.01)],
        [F5.transpose(-0.01),C4.transpose(-0.01)],
      ].each do |start,finish|
        context "start at #{start.to_s}, target #{finish.to_s}" do
          pitches = GlissandoConverter.glissando_pitches(start,finish)

          it 'should move down to next whole (zero-cent) pitches' do
            (1...pitches.size).each do |i|
              expect(pitches[i].cent).to eq(0)
              expect(pitches[i-1].diff(pitches[i])).to be <= 1
            end
          end

          it 'should end on the whole (zero-cent) pitch above target pitch' do
            expect(pitches.last.cent).to eq(0)
            diff = pitches.last.total_cents - finish.total_cents
            expect(diff).to be <= 100
          end

        end
      end
    end
  end

  describe '.glissando_elements' do
    before :all do
      @dur = Rational(3,2)
      @att = Attack::TENUTO
      @els = GlissandoConverter.glissando_elements(C4,A4,@dur,@att)
    end

    it 'should return an array of NoteSequence::Element objects' do
      @els.each {|el| expect(el).to be_a NoteSequence::Element }
    end

    it 'should split up duration among elements' do
      sum = @els.map {|el| el.duration }.inject(0,:+)
      expect(sum).to eq(@dur)
    end

    it 'should set attack as given for each element' do
      els = GlissandoConverter.glissando_elements(C4,A4,1,Attack::TENUTO)
      els.each {|el| expect(el.attack).to eq(Attack::TENUTO) }
      els = GlissandoConverter.glissando_elements(C4,A4,1,Attack::ACCENT)
      els.each {|el| expect(el.attack).to eq(Attack::ACCENT) }
    end
  end
end
