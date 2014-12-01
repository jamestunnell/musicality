require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe PartSequencer do
  describe '#make_midi_track' do
    before :all do
      part = Part.new(Dynamics::PP, notes: "/4C4 /4D4 /8 /8D4 /8E4 /2C4".to_notes * 2,
                      dynamic_changes: { 1 => Change::Gradual.linear(Dynamics::FF,2) })
      @midi_seq = MIDI::Sequence.new
      @part_name = "mypart"
      @channel = 2
      @ppqn = 200
      @program_num = 22
      @track = PartSequencer.new(part).make_midi_track(@midi_seq,@part_name,@channel,@ppqn,@program_num)
    end
    
    it 'should return MIDI::Track' do
      @track.should be_a MIDI::Track
    end
    
    it 'should assign part name to track name' do
      @track.name.should eq(@part_name)
    end
    
    it 'should assign program number via ProgramChange event' do
      event = @track.events.select { |x| x.is_a? MIDI::ProgramChange }.first
      event.program.should eq(@program_num)
    end
    
    it 'should assign the given channel number to all channel events' do
      @track.events.each do |event|
        if event.is_a? MIDI::ChannelEvent
          event.channel.should eq(@channel)
        end
      end
    end
    
    it 'should not add the track to the given midi seq' do
      @midi_seq.tracks.should_not include(@track)
    end
  end
end
