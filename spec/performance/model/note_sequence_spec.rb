require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NoteSequence do
  describe '#initialize' do
    it 'should assign given offset, separation, and elements' do
      offset = 12
      separation = Separation::TENUTO
      elements = [ NoteSequence::Element.new(2, G2, Attack::NORMAL) ]
      
      seq = NoteSequence.new(offset, separation, elements)
      expect(seq.offset).to eq(offset)
      expect(seq.separation).to eq(separation)
      expect(seq.elements).to eq(elements)
    end
  end

  before :all do
    @element_ary = [
      NoteSequence::Element.new(0.5, A2, Attack::NORMAL), 
      NoteSequence::Element.new(0.5, B2, Attack::NONE),
      NoteSequence::Element.new(0.5, B2, Attack::ACCENT)
    ]
    @offsets = [ 0, -5, 7, 77 ]
  end
  
  describe '#offsets' do
    context 'with no elements' do
      it 'should raise RuntimeError' do
        expect do
          seq = NoteSequence.new(0, Separation::NORMAL, [])
          seq.offsets
        end.to raise_error(RuntimeError)
      end
    end
    
    context 'with at least one element' do
      it 'should return offsets of each element' do
        @offsets.each do |offset|
          @element_ary.combination(@element_ary.size-1).each do |els|
            seq = NoteSequence.new(offset, Separation::NORMAL, els)
            offsets = seq.offsets
            expect(offsets.size).to eq(els.size)
            expect(offsets[0]).to eq(seq.offset)
            (1...offsets.size).each do |i|
              dur = offsets[i] - offsets[i-1]
              expect(dur).to eq(els[i-1].duration)
            end
          end
        end
      end
    end
  end

  describe '#stop' do
    context 'no elements' do
      it 'should raise RuntimeError' do
        ns = NoteSequence.new(1.2, Separation::NORMAL, [])
        expect { ns.stop }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#duration' do
    context 'no elements' do
      it 'should raise RuntimeError' do
        ns = NoteSequence.new(1.2, Separation::NORMAL, [])
        expect { ns.duration }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#full_duration' do
    context 'no elements' do
      it 'should return 0' do
        ns = NoteSequence.new(1.2, Separation::NORMAL, [])
        expect(ns.full_duration).to eq(0)
      end
    end

    context 'with one element' do
      it 'should return element duration' do
        @element_ary.each do |el|
          ns = NoteSequence.new(1.2, Separation::NORMAL, [el])
          expect(ns.full_duration).to eq(el.duration)
        end
      end
    end

    context 'with multiple elements' do
      it 'should return the sum of element durations' do
        els = [ NoteSequence::Element.new(0.5, D4, Attack::NORMAL),
          NoteSequence::Element.new(0.25, F3, Attack::TENUTO) ]
        ns = NoteSequence.new(1.2, Separation::NORMAL, els)
        expect(ns.full_duration).to eq(0.75)
      end
    end
  end
end