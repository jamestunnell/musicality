require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Note do
  before :all do
    @pitch = C4
  end
  
  describe '.new' do
    it 'should assign :duration that is given during construction' do
      Note.new(2).duration.should eq(2)
    end

    it "should assign :articulation to Note::DEFAULT_ARTICULATION if not given" do
      Note.new(2).articulation.should eq(Note::DEFAULT_ARTICULATION)
    end
    
    it "should assign :articulation parameter if given during construction" do
      Note.new(2, articulation: STACCATO).articulation.should eq(STACCATO)
    end
    
    it 'should assign :accented to false if not given' do
      Note.new(2).accented.should be false
    end
    
    it 'should assign :accented if given' do
      Note.new(2, accented: true).accented.should be true
    end
    
    it 'should have no pitches if not given' do
      Note.new(2).pitches.should be_empty
    end
    
    it 'should assign pitches when given' do
      pitches = [ C2, D2 ]
      n = Note.new(2, pitches)
      n.pitches.should include(pitches[0])
      n.pitches.should include(pitches[1])
    end
  end
  
  describe '#duration=' do
    it 'should assign duration' do
      note = Note.new 2, [@pitch]
      note.duration = 3
      note.duration.should eq 3
    end
  end
  
  {
    :sixteenth => Rational(1,16),
    :dotted_SIXTEENTH => Rational(3,32),
    :eighth => Rational(1,8),
    :dotted_eighth => Rational(3,16),
    :quarter => Rational(1,4),
    :dotted_quarter => Rational(3,8),
    :half => Rational(1,2),
    :dotted_half => Rational(3,4),
    :whole => Rational(1)
  }.each do |fn_name,tgt_dur|
    describe ".#{fn_name}" do
      it "should make a note with duration #{tgt_dur}" do
        Note.send(fn_name).duration.should eq tgt_dur
      end
    end
  end
  
  describe '#transpose' do
    context 'given pitch diff' do
      before(:all) do
        @note1 = Note::quarter([C2,F2], links:{C2=>Link::Glissando.new(D2)})
        @interval = 4
        @note2 = @note1.transpose(@interval)
      end
        
      it 'should modifiy pitches by adding pitch diff' do
        @note2.pitches.each_with_index do |p,i|
          p.diff(@note1.pitches[i]).should eq(@interval)
        end
      end
        
      it 'should also affect link targets' do
        @note1.links.each do |k,v|
          kt = k.transpose(@interval)
          @note2.links.should have_key kt
          @note2.links[kt].target_pitch.should eq(v.target_pitch.transpose(@interval))
        end
      end
    end
    
    context 'with links that have no target pitch' do
      it 'should not raise error' do
        n = Note::half([E2],links: {E2 => Link::Tie.new})
        expect { n.transpose(1) }.to_not raise_error
      end
    end
  end
  
  describe '#stretch' do
    it 'should multiply note duration by ratio' do
      note = Note::quarter.stretch(2)
      note.duration.should eq(Rational(1,2))
      
      note = Note::quarter.stretch(Rational(1,2))
      note.duration.should eq(Rational(1,8))
    end
  end
  
  describe '#to_s' do
    before :all do
      @note_parser = Parsing::NoteParser.new
    end
    
    context 
    it 'should produce string that when parsed produces an equal note' do
      durations = ["1/8".to_r,"1".to_r,"5/3".to_r]
      include Articulations
      articulations = [NORMAL, SLUR, LEGATO, TENUTO, PORTATO, STACCATO, STACCATISSIMO ]
      pitches_links_sets = [
        [[],{}],
        [[C2],{}],
        [[A5,D6],{ A5 => Link::Tie.new }],
        [[C5,E6,Gb2],{ C5 => Link::Glissando.new(D5) }],
        [[C5,E6,Gb2],{ C5 => Link::Portamento.new(D5), Gb2 => Link::Tie.new }],
      ]
      
      notes = []
      durations.each do |d|
        pitches_links_sets.each do |pitches_links_set|
          pitches,links = pitches_links_set
          if pitches.any?
            articulations.each do |art|
              [true,false].each do |acc|
                notes.push Note.new(d, pitches, articulation: art, links: links, accented: acc)
              end
            end
          else
            notes.push Note.new(d)
          end
        end
      end
      
      notes.each do |note|
        str = note.to_s
        res = @note_parser.parse(str)
        note2 = res.to_note
        note2.should eq(note)
      end
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      n = Note.new(1,[C2])
      YAML.load(n.to_yaml).should eq n
      
      n = Note.new(1,[C2,E2])
      YAML.load(n.to_yaml).should eq n
      
      n = Note.new(1,[C2], articulation: STACCATO)
      YAML.load(n.to_yaml).should eq n
      
      n = Note.new(1,[E2], links: {E2 => Link::Portamento.new(F2)})
      YAML.load(n.to_yaml).should eq n
    end
  end
  
  describe '#valid?' do
    context 'note with positive duration' do
      it 'should return true' do
        Note.new(1,[C2]).should be_valid
      end
    end
    
    context 'note with 0 duration' do
      it 'should return false' do
        Note.new(0,[C2]).should be_invalid
      end
    end
    
    context 'note with negative duration' do
      it 'should be invalid' do
        Note.new(-1,[C2]).should be_invalid
      end
    end
  end
end
