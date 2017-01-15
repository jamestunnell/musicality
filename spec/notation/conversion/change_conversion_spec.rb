require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Change::Immediate do
  describe '#offsets' do
    it 'should return array with just the given base offset' do
      c = Change::Immediate.new(12)
      expect(c.offsets(44)).to eq([44])
    end
  end

  describe '#remap' do
    it 'should return a clone of the change' do
      c = Change::Immediate.new(12)
      c2 = c.remap(1,{})
      expect(c2).to eq(c)
      expect(c2).to_not be c
    end
  end

  describe '#to_transition' do
    before :all do
      @ch = Change::Immediate.new(20)
      @off = 0
      @f = @ch.to_transition(@off,0)
    end

    it 'should return a peicewise function' do
      expect(@f).to be_a Function::Piecewise
    end

    it 'should return a function defined from base offset to DOMAIN_MAX' do
      expect(@f.domain_include?(@off)).to be true
      expect(@f.domain_include?(Function::DOMAIN_MAX)).to be true
    end

    it 'should return change value from base offset onward' do
      expect(@f.at(@off)).to eq(@ch.end_value)
      expect(@f.at(@off+1)).to eq(@ch.end_value)
      expect(@f.at(@off+1000)).to eq(@ch.end_value)
    end
  end
end

describe Change::Gradual do
  before :all do
    @change = Change::Gradual.linear(100,1.5)
    @base = 25.5
  end

  describe '#offsets' do
    before :all do
      @offsets = @change.offsets(@base)
    end

    it 'should return array with 2 elements' do
      expect(@offsets.size).to eq(2)
    end

    it 'should include the given base offset' do
      expect(@offsets).to include(@base)
    end

    it 'should include the base offset + duration' do
      expect(@offsets).to include(@base + @change.duration)
    end
  end

  describe '#remap' do
    before :all do
      @c2 = @change.remap(@base, @base => 3, (@base + @change.duration) => 5)
    end

    it 'should return a new Gradual' do
      expect(@c2).to be_a(Change::Gradual)
      expect(@c2).to_not be(@change)
    end

    it 'should keep end value, and change duration based on given offset map' do
      expect(@c2.end_value).to eq(@change.end_value)
      expect(@c2.duration).to eq(2)
    end
  end

  describe '#to_transition' do
    { 'linear transition' => Change::Gradual.linear(130,20),
      'sigmoid transition' => Change::Gradual.sigmoid(130,20)
    }.each do |descr, change|
      context descr do
        before :all do
          @offset = 3
          @start_value = 50
          @func = @change.to_transition(@offset, @start_value)
        end

        it 'should return a piecewise function' do
          expect(@func).to be_a Function::Piecewise
        end

        it 'should return a function that is undefined before base offset' do
          expect(@func.domain_include?(@offset-1e-5)).to be false
          expect(@func.domain_include?(@offset-1e5)).to be false
        end

        it 'should return a function defined from base offset to DOMAIN_MAX' do
          expect(@func.domain_include?(@offset)).to be true
          expect(@func.domain_include?(@offset + @change.duration/2.0)).to be true
          expect(@func.domain_include?(@offset + @change.duration)).to be true
          expect(@func.domain_include?(@offset + @change.duration + 1)).to be true
          expect(@func.domain_include?(Function::DOMAIN_MAX)).to be true
        end

        it 'should make function that evaluates to start_value at start offset' do
          expect(@func.at(@offset)).to eq(@start_value)
        end

        it 'should make function that evaluates to end_value at start offset + duration' do
          expect(@func.at(@offset + @change.duration)).to eq(@change.end_value)
        end

        it 'should make function that evaluates to 1/2 between start/end value at 1/2 between start/end offset' do
          tgt = (@change.end_value + @start_value) / 2.0
          expect(@func.at(@offset + @change.duration/2.0)).to be_within(1e-5).of(tgt)
        end

        it 'should make function that evaluates to end value after change has elapsed' do
          expect(@func.at(@offset + @change.duration + 1)).to eq(@change.end_value)
        end
      end
    end

    context 'start value already defined in change' do
      { 'linear transition' => Change::Gradual.linear(130,20,start_value:80),
        'sigmoid transition' => Change::Gradual.sigmoid(130,20,start_value:80)
      }.each do |descr, change|
        context descr do
          it 'should produce a function that begins at already-defined start value' do
            offset = 3
            start_value = 50
            func = change.to_transition(offset, start_value)
            expect(func.at(offset)).to eq(change.start_value)
          end
        end
      end
    end
  end
end

describe Change::Gradual::Trimmed do
  before :all do
    @change = Change::Gradual.linear(100,1.5.to_r).to_trimmed(0.5.to_r,0.5.to_r)
    @base = 25.5.to_r
  end

  describe '#offsets' do
    before :all do
      @offsets = @change.offsets(@base)
    end

    it 'should return array with 2 elements' do
      expect(@offsets.size).to eq(4)
    end

    it 'should include the given base offset' do
      expect(@offsets).to include(@base)
    end

    it 'should include the base offset - preceding' do
      expect(@offsets).to include(@base - @change.preceding)
    end

    it 'should include the base offset + remaining' do
      expect(@offsets).to include(@base + @change.remaining)
    end

    it 'should include the base offset - preceding + duration' do
      expect(@offsets).to include(@base - @change.preceding + @change.duration)
    end
  end

  describe '#remap' do
    before :all do
      @offsets = { @base => 3, (@base - @change.preceding) => 0,
        (@base + @change.remaining) => 5, (@base - @change.preceding + @change.duration) => 7 }
      @c2 = @change.remap(@base, @offsets)
    end

    it 'should return a new Gradual::Trimmed' do
      expect(@c2).to be_a(Change::Gradual::Trimmed)
      expect(@c2).to_not be(@change)
    end

    it 'should keep end value, and change duration based on given offset map' do
      expect(@c2.end_value).to eq(@change.end_value)
      expect(@c2.duration).to eq(7)
      expect(@c2.preceding).to eq(3)
      expect(@c2.remaining).to eq(2)
    end
  end

  describe '#to_transition' do
    Change::Gradual::TRANSITIONS.each do |transition|
      context "#{transition} transition" do
        [nil,35].each do |start_val|
          context "change start_value = #{start_val}" do
            before :all do
              untrimmed = Change::Gradual.new(130,20, transition, start_value: start_val)
              untrimmed_offset = 0
              untrimmed_start_val = 50
              @untrimmed_trans = untrimmed.to_transition(untrimmed_offset, untrimmed_start_val)

              trimmed = untrimmed.trim(5,3)
              trimmed_offset = untrimmed_offset + trimmed.preceding
              trimmed_start_val = @untrimmed_trans.at(trimmed_offset)
              @trimmed_trans = trimmed.to_transition(trimmed_offset, trimmed_start_val)

              @xrange = trimmed_offset..(trimmed_offset + trimmed.remaining)
            end

            it 'should produce function that is undefined before trimmed domain' do
              expect(@trimmed_trans.domain_include?(@xrange.first-1)).to be false
            end

            it 'should produce function that is defined for trimmed domain' do
              expect(@trimmed_trans.domain_include?(@xrange.first)).to be true
              expect(@trimmed_trans.domain_include?((@xrange.first + @xrange.last)/2.0)).to be true
              expect(@trimmed_trans.domain_include?(@xrange.last)).to be true
            end

            it 'should produce function that is defined after trimmed domain' do
              expect(@trimmed_trans.domain_include?(@xrange.last+1)).to be true
              expect(@trimmed_trans.domain_include?(Function::DOMAIN_MAX)).to be true
            end

            it 'should produce function that stays at end value after transition' do
              expect(@trimmed_trans.at(@xrange.last + 1)).to eq(@trimmed_trans.at(@xrange.last))
            end

            it 'should produce function that samples same as equivalent untrimmed' do
              srate = 50
              expect(@trimmed_trans.sample(@xrange, srate)).to eq(@untrimmed_trans.sample(@xrange, srate))
            end
          end
        end
      end
    end
  end
end
