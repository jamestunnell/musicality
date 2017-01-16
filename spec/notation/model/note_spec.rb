require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

describe Note do
  before :all do
    @pitch = C4
  end

  describe '#initialize' do
    it 'should assign :duration that is given during construction' do
      expect(Note.new(2).duration).to eq(2)
    end

    it "should assign :articulation to NORMAL if not given" do
      expect(Note.new(2).articulation).to eq(NORMAL)
    end

    it "should assign :articulation parameter if given during construction" do
      expect(Note.new(2, articulation: STACCATO).articulation).to eq(STACCATO)
    end

    it 'should assign :marks to [] if not given' do
      expect(Note.new(2).marks).to eq([])
    end

    it 'should assign :marks if given' do
      [
        [], [BEGIN_SLUR], [END_SLUR]
      ].each do |marks|
        expect(Note.quarter(marks: marks).marks).to eq(marks)
      end
    end

    it 'should have no pitches if not given' do
      expect(Note.new(2).pitches).to be_empty
    end

    it 'should assign pitches when given' do
      pitches = [ C2, D2 ]
      n = Note.new(2, pitches)
      expect(n.pitches).to include(pitches[0])
      expect(n.pitches).to include(pitches[1])
    end
  end

  describe '#duration=' do
    it 'should assign duration' do
      note = Note.new 2, [@pitch]
      note.duration = 3
      expect(note.duration).to eq 3
    end
  end

  {
    :sixteenth => Rational(1,16),
    :dotted_sixteenth => Rational(3,32),
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
        expect(Note.send(fn_name).duration).to eq tgt_dur
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
          expect(p.diff(@note1.pitches[i])).to eq(@interval)
        end
      end

      it 'should also affect link targets' do
        @note1.links.each do |k,v|
          kt = k.transpose(@interval)
          expect(@note2.links).to have_key kt
          expect(@note2.links[kt].target_pitch).to eq(v.target_pitch.transpose(@interval))
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

  describe '#resize' do
    it 'should return new note object with given duration' do
      note = Note::quarter.resize("1/2".to_r)
      expect(note.duration).to eq(Rational(1,2))
    end
  end

  describe '#tie_to' do
    context 'given a pitch object' do
      it 'should return new note object tied to given pitch' do
        note = Note.half(@pitch).tie_to(@pitch)
        expect(note.links).to have_key(@pitch)
        expect(note.links[@pitch]).to be_a Link::Tie
      end
    end

    context 'given an array of pitch objects' do
      it 'should return new note object tied to given pitches' do
        pitches = [@pitch,@pitch+1]
        note = Note.half(pitches).tie_to(pitches)
        pitches.each do |pitch|
          expect(note.links).to have_key(pitch)
          expect(note.links[pitch]).to be_a Link::Tie
        end
      end
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
      articulations = [NORMAL, TENUTO, MARCATO, ACCENT, PORTATO, STACCATO, STACCATISSIMO ]
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
              [[],[BEGIN_SLUR],[END_SLUR]].each do |marks|
                notes.push Note.new(d, pitches, articulation: art, links: links, marks: marks)
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
        expect(note2).to eq(note)
      end
    end
  end

  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      n = Note.new(1,[C2])
      expect(YAML.load(n.to_yaml)).to eq n

      n = Note.new(1,[C2,E2])
      expect(YAML.load(n.to_yaml)).to eq n

      n = Note.new(1,[C2], articulation: STACCATO)
      expect(YAML.load(n.to_yaml)).to eq n

      n = Note.new(1,[E2], links: {E2 => Link::Portamento.new(F2)})
      expect(YAML.load(n.to_yaml)).to eq n
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      n = Note.quarter([E2,F2,A2], articulation: STACCATO, marks: [BEGIN_SLUR], links: {E2 => Link::Tie.new, F2 => Link::Glissando.new(C3)})
      expect(n.pack).to be_a Hash
    end
  end

  describe 'unpack' do
    it 'should produce an object equal the original' do
      n = Note.quarter([E2,F2,A2], articulation: STACCATO, marks: [BEGIN_SLUR], links: {E2 => Link::Tie.new, F2 => Link::Glissando.new(C3)})
      n2 = Note.unpack n.pack
      expect(n2).to be_a Note
      expect(n2).to eq n
    end
  end

  describe '#valid?' do
    context 'note with positive duration' do
      it 'should return true' do
        expect(Note.new(1,[C2])).to be_valid
      end
    end
  end
end
