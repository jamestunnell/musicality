require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Note do
  describe '#to_lilypond' do
    context 'simple power-of-two note duration' do
      context 'no pitches' do
        it 'should return a string with "r" plus the duration denominator' do
          [1,0.5,0.25,0.125,0.0625].each do |dur|
            n = Note.new(dur.to_r)
            n.to_lilypond.should eq("r" + n.duration.denominator.to_s)
          end
        end
      end

      context 'one pitch' do
        it 'should return a string with Lilypond pitch plus the duration denominator' do
          [1,0.5,0.25,0.125,0.0625].each do |dur|
            [C3,Eb2,G4].each do |pitch|
              n = Note.new(dur.to_r, pitch)
              n.to_lilypond.should eq(pitch.to_lilypond + n.duration.denominator.to_s)
            end
          end
        end
      end

      context 'multiple pitch' do
        it 'should return a string with Lilypond pitches in angle brackets plus the duration denominator' do
          [1,0.25,0.0625].each do |dur|
            pitch_group = [Eb2,C3,G4]
            n = Note.new(dur.to_r, pitch_group)
            n.to_lilypond.should eq("<" + pitch_group.map {|p| p.to_lilypond}.join(" ") + ">" + n.duration.denominator.to_s)
          end
        end
      end
    end

    context 'dotted power-of-two note duration less than 1 (e.g. 3/4 or 3/2)' do
      context 'no pitches' do
        it 'should return a string with "r" plus half the duration denominator plus a "."' do
          [0.75,0.375].each do |dur|
            n = Note.new(dur.to_r)
            n.to_lilypond.should eq("r" + (n.duration.denominator/2).to_s + ".")
          end
        end
      end

      context 'one pitch' do
        it 'should return a string with Lilypond pitch plus half the duration denominator plus a "."' do
          [0.75,0.375].each do |dur|
            [C3,Eb2,G4].each do |pitch|
              n = Note.new(dur.to_r, pitch)
              n.to_lilypond.should eq(pitch.to_lilypond + (n.duration.denominator/2).to_s + ".")
            end
          end
        end
      end

      context 'multiple pitch' do
        it 'should return a string with Lilypond pitches in angle brackets plus half the duration denominator plus a "."' do
          [0.75,0.375].each do |dur|
            pitch_group = [Eb2,C3,G4]
            n = Note.new(dur.to_r, pitch_group)
            n.to_lilypond.should eq("<" + pitch_group.map {|p| p.to_lilypond}.join(" ") + ">" + (n.duration.denominator/2).to_s + ".")
          end
        end
      end
    end
  end
end
