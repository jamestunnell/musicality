require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Rhythm do
  describe '.new' do
    it 'should raise ArgumentError if given durations contains any zero(s)' do
      expect { Rhythm.new([1,0,2]) }.to raise_error(ArgumentError)
    end
  end

  describe '#durations' do
    it 'should return the same portions given initially' do
      durations = [4,2,-2,-1]
      rc = Rhythm.new(durations)
      expect(rc.durations).to eq(durations)
    end
  end

  describe '#durations_sum' do
    it 'should return the sum of durations using their absolute value' do
      rc = Rhythm.new([4,2,-2,-1])
      expect(rc.durations_sum).to eq(9)
    end
  end

  describe '#to_notes' do
    it 'should produce the expected Note objects' do
      durations = [Rational(1,2), Rational(2,1), Rational(2,3)]
      rhythm = Rhythm.new(durations)
      durations_sum = rhythm.durations_sum
      pitch = Pitches::C4
      notes = rhythm.to_notes(pitch)

      expect(notes.size).to eq(durations.size)
      notes.each do |note|
        expect(note).to be_a(Note)
      end
      durations.each_with_index do |dur, idx|
        dur2 = notes[idx].duration
        expect(dur).to eq(dur2)
      end
    end
  end
end
