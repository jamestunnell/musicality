require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NoteScore do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = NoteScore.new(30)
      s.parts.should be_empty
      s.program.segments.should be_empty
    end
    
    it 'should assign given parameters' do
      s = NoteScore.new(30)
      s.start_tempo.should eq(30)
      
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = Program.new [0...0.75, 0...0.75]
      tcs = { 1 => Change::Immediate.new(40) }
      
      s = NoteScore.new(30,
        parts: parts,
        program: program,
        tempo_changes: tcs
      )
      s.parts.should eq parts
      s.program.should eq program
      s.tempo_changes.should eq tcs
    end
  end
  
  describe '#valid?' do
    {
      'valid start tempo' => [ 40 ],
      'valid tempo changes' => [ 30,
        :tempo_changes => { 1 => Change::Gradual.new(40, 2), 2 => Change::Immediate.new(50) } ],
      'valid part' => [ 30, :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ 30, :program => Program.new([0..2,0..2]) ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          NoteScore.new(*args).should be_valid
        end
      end
    end
    
    {
      'start tempo valid is zero' => [ 0 ],
      'start tempo valid is negative' => [ -1 ],
      'tempo change value is not a valid value' => [ 30,
        :tempo_changes => { 1 => Change::Gradual.new(-1,1) } ],
      'invalid part' => [ 30, :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ 30, :program => Program.new([2..0]) ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          NoteScore.new(*args).should be_invalid
        end
      end 
    end
  end
end
