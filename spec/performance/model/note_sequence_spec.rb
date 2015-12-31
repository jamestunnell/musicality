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
    @element_arys = [
      [ NoteSequence::Element.new(0.5, B2, Attack::NONE) ],
      [ NoteSequence::Element.new(0.5, A2, Attack::NORMAL), 
        NoteSequence::Element.new(0.5, B2, Attack::NONE),
        NoteSequence::Element.new(0.5, B2, Attack::ACCENT) ],
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
          @element_arys.each do |els|
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
end