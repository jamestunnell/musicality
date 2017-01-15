require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Note do
  describe '#fractional_subdurs' do
    context 'duration that is entirely whole' do
      it 'should return empty array' do
        [1,2,3,4,7,11].each do |dur|
          subdurs = Note.new(dur).fractional_subdurs(Rational(1,32))
          expect(subdurs).to be_empty
        end
      end
    end

    context 'duration that is entirely fractional' do
      context 'combination of multiples of power-of-two fractions' do
        [
          [Rational(3,8),Rational(7,32)],
          [Rational(1,8),Rational(3,16),Rational(5,32)],
          [Rational(1,2),Rational(3,32),Rational(5,64),Rational(17,128)],
        ].each do |subdurs|
          dur = subdurs.inject(0.to_r,:+)
          n = Note.new(dur)
          subdurs2 = n.fractional_subdurs(Rational(1,512))

          it 'should return descending power-of-two fractions' do
            expect(subdurs2).to eq subdurs2.sort.reverse
          end

          it 'should return fractions that sum to note duration' do
            expect(subdurs2.inject(0.to_r,:+)).to eq(dur)
          end
        end
      end
    end

    context 'duration that has whole and fractional part' do
      [
        [6,Rational(3,8),Rational(11,16)],
        [3,Rational(1,8),Rational(5,8),Rational(5,32)],
        [1,Rational(3,32),Rational(1,2),Rational(5,4)],
      ].each do |subdurs|
        dur = subdurs.inject(0.to_r,:+)
        n = Note.new(dur)
        subdurs2 = n.fractional_subdurs(Rational(1,1024))

        it 'should return fractions that sum to fractional note duration' do
          expect(subdurs2.inject(0.to_r,:+)).to eq(dur - dur.to_i)
        end
      end
    end
  end

  describe '#to_lilypond' do
    context 'duration is entirely whole' do
      context 'no pitches' do
        it 'should return "r1"s' do
        end
      end
    end
  end

  #   context 'no pitches' do
  #     it 'should represent note pieces with "r"' do

  #     end
  #   end

  #   it 'should '
  #   it 'should separate pieces with a "~" and a space' do
  #     [2,3+Rational(1,2)].each do |dur|
  #       [[],[Eb3],[C2,Gb4]].each do |pitches|
  #         n = Note.new(dur,pitches)
  #         s = n.to_lilypond
  #         pieces = s.split("~ ")
  #         pieces.
  #       end
  #     end
  #   end


    #    and duration with deno'
    #   context 'simple power-of-two note duration' do
    #     it 'should return a string with "r" plus the duration denominator' do
    #       [1,0.5,0.25,0.125,0.0625].each do |dur|
    #         n = Note.new(dur.to_r)
    #         expect(n.to_lilypond).to eq("r" + n.duration.denominator.to_s)
    #       end
    #     end
    #   end

    #   context 'dotted power-of-two note duration less than 1 (e.g. 3/4 or 3/2)' do
    #     it 'should return a string with "r" plus half the duration denominator plus a "."' do
    #       [0.75,0.375].each do |dur|
    #         n = Note.new(dur.to_r)
    #         expect(n.to_lilypond).to eq("r" + (n.duration.denominator/2).to_s + ".")
    #       end
    #     end
    #   end

    #   context 'compound duration reducible only to simple power-of-two durations (not dotted)' do
    #     it 'should return a string with r\'s plus the duration denominators' do
    #       [
    #         [1,0.25],
    #         [0.5,0.125],
    #         [0.25,0.0625],
    #         [0.5,0.125,0.03125]
    #       ].each do |subdurs|
    #         dur = subdurs.inject(0.to_r,:+)
    #         n = Note.new(dur)
    #         strs = n.to_lilypond.split
    #         expect(strs.size).to eq subdurs.size
    #         strs.each_with_index do |str,i|
    #           expect(str).to eq("r" + subdurs[i].to_r.denominator.to_s)
    #         end
    #       end
    #     end
    #   end

    #   context 'simple triplet duration' do
    #     it 'should return "r" + 3/2 duration enclosed inside \tuplet 3/2 {}' do
    #       [Rational(1,6),Rational(1,3),Rational(1,12)].each do |dur|
    #         n = Note.new(dur.to_r)
    #         expect(n.to_lilypond).to eq("\\tuplet 3/2 {r#{(1.5.to_r*dur).denominator}}")
    #       end
    #     end
    #   end
    # end

    # context 'simple power-of-two note duration' do
    #   context 'one pitch' do
    #     it 'should return a string with Lilypond pitch plus the duration denominator' do
    #       [1,0.5,0.25,0.125,0.0625].each do |dur|
    #         [C3,Eb2,G4].each do |pitch|
    #           n = Note.new(dur.to_r, pitch)
    #           expect(n.to_lilypond).to eq(pitch.to_lilypond + n.duration.denominator.to_s)
    #         end
    #       end
    #     end
    #   end

    #   context 'multiple pitch' do
    #     it 'should return a string with Lilypond pitches in angle brackets plus the duration denominator' do
    #       [1,0.25,0.0625].each do |dur|
    #         pitch_group = [Eb2,C3,G4]
    #         n = Note.new(dur.to_r, pitch_group)
    #         expect(n.to_lilypond).to eq("<" + pitch_group.map {|p| p.to_lilypond}.join(" ") + ">" + n.duration.denominator.to_s)
    #       end
    #     end
    #   end
    # end

    # context 'dotted power-of-two note duration less than 1 (e.g. 3/4 or 3/2)' do
    #   context 'one pitch' do
    #     it 'should return a string with Lilypond pitch plus half the duration denominator plus a "."' do
    #       [0.75,0.375].each do |dur|
    #         [C3,Eb2,G4].each do |pitch|
    #           n = Note.new(dur.to_r, pitch)
    #           expect(n.to_lilypond).to eq(pitch.to_lilypond + (n.duration.denominator/2).to_s + ".")
    #         end
    #       end
    #     end
    #   end

    #   context 'multiple pitch' do
    #     it 'should return a string with Lilypond pitches in angle brackets plus half the duration denominator plus a "."' do
    #       [0.75,0.375].each do |dur|
    #         pitch_group = [Eb2,C3,G4]
    #         n = Note.new(dur.to_r, pitch_group)
    #         expect(n.to_lilypond).to eq("<" + pitch_group.map {|p| p.to_lilypond}.join(" ") + ">" + (n.duration.denominator/2).to_s + ".")
    #       end
    #     end
    #   end
    # end

    # context 'compound duration reducible only to simple power-of-two durations (not dotted)' do
    #   context 'one pitch' do
    #     it 'should return a string with Lilypond pitch plus the duration denominators, and a "~" if not the last piece' do
    #       [
    #         [1,0.25],
    #         [0.5,0.125],
    #         [0.25,0.0625],
    #         [0.5,0.125,0.03125]
    #       ].each do |subdurs|
    #         [Gb3,Bb3,C4].each do |pitch|
    #           dur = subdurs.inject(0.to_r,:+)
    #           n = Note.new(dur,pitch)
    #           str = n.to_lilypond
    #           strs = str.split
    #           expect(strs.size).to eq subdurs.size
    #           strs.each_with_index do |str,i|
    #             if i != (strs.size-1)
    #               expect(str).to eq(pitch.to_lilypond + subdurs[i].to_r.denominator.to_s + "~")
    #             else
    #               expect(str).to eq(pitch.to_lilypond + subdurs[i].to_r.denominator.to_s)
    #             end
    #           end
    #         end
    #       end
    #     end
    #   end

    # end
  # end
end
