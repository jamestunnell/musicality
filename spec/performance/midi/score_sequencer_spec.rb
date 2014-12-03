require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ScoreSequencer do
  describe '#initialize' do
  end
  
  describe '#make_midi_seq' do
    before :all do
      @part1_name = "abc"
      @part2_name = "def"
      @part1 = Part.new(Dynamics::PP, notes: "/4C4 /4D4 /8 /8D4 /8E4 3/8C4".to_notes * 2)
      @part2 = Part.new(Dynamics::FF, notes: "/4E4 3/4F4 /4E4".to_notes * 2)
      @score = Score::Timed.new(program: Program.new(0..2.5),
                                parts: {@part1_name => @part2, @part2_name => @part2})
      @instr_map = {@part1_name => 33, @part2_name => 25}
      @midi_seq = ScoreSequencer.new(@score).make_midi_seq(@instr_map)
    end
    
    it 'should return MIDI::Sequence' do
      @midi_seq.should be_a MIDI::Sequence
    end
    
    it 'should have 1 track for each part, plus one for score meta events' do
      @midi_seq.tracks.size.should eq(@score.parts.size + 1)
    end
    
    it 'should add a midi track for each part' do
      @midi_seq.tracks[1].name.should eq(@part1_name)
      @midi_seq.tracks[2].name.should eq(@part2_name)
    end
    
    it 'should assign program number from given instrument map hash' do
      [ @midi_seq.tracks[1], @midi_seq.tracks[2] ].each do |track|
        prog_event = track.events.select {|x| x.is_a? MIDI::ProgramChange }.first
        prog_event.program.should eq(@instr_map[track.name])
      end
    end
    
    it 'should assign different channel to each part track' do
      chs_so_far = []
      [ @midi_seq.tracks[1], @midi_seq.tracks[2] ].each do |track|
        channel_events = track.events.select {|x| x.is_a? MIDI::ChannelEvent }
        chs = channel_events.map {|event| event.channel }.uniq
        chs.size.should eq 1
        chs_so_far.should_not include(chs[0])
        chs_so_far.push chs[0]
      end
    end
  end
end