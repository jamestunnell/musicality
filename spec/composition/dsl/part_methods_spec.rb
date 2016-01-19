require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Part do
  describe '#dynamic_change' do
    before :each do
      @part = Part.new(Dynamics::MP, notes: "/4 /4D4 /8C3 /16C3".to_notes)
    end

    context 'transition_dur is 0' do
      context 'offset is 0' do
        it 'should create an immediate dynamic change at the end of the part' do
          @part.dynamic_change Dynamics::PP
          expect(@part.dynamic_changes.size).to eq(1)
          expect(@part.dynamic_changes).to have_key(@part.duration)
          expect(@part.dynamic_changes.values.first).to eq Change::Immediate.new(Dynamics::PP)
        end
      end

      context 'offset is not 0'
    end

    context 'transition_dur is not 0'
  end
end
