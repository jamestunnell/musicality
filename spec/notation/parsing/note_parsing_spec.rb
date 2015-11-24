require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::NoteParser do
  before :all do
    @parser = Parsing::NoteParser.new
  end
  
   valid_cases = {
    'duration only' => ['1/4','/2','1','55/33'],
    'single pitch' => ['/4C2','5/3Db3','/33E#8'],
    'multiple pitches' => ['/4C2,C3,c5','5/3Db3,Bb2,E5','/33E#8,F1,B9'],
    'with articulation' => ['/4C2.',"5/3Db3,Bb2,E5.",'/33F3(','/2D3,F4_'],
    'with accent' => ['/4C2','3/2Db3,Bb4'],
    'with links' => ['/2C2~','/2C2:D2','/4D4:E4,G4;A5.'],
    'with single pitch + articulation + link + accent' => [
      '3/4D2~(','5/8F2;G2.','/8Db4:Db5','/3G4;B4_'],
    'with multiple pitches + articulation + links + accent' => [
      '5/4D2~,G4:A4,C3;D3.','5/8F2~,B4:A4_'],
  }
  invalid_cases = {
    'duration + articulation' => ['1/4.','/2.','2/3!'],
    'duration + accent + link' => ['1/4;','/2:','2/3~'],
    'single pith with bad letter' => ['5/3Hb3'],
    'single pitch without octave' => ['/33E(2'],
  }
  
  valid_cases.each do |descr, strs|
    context(descr + ' (valid)') do
      it 'should parse' do
        strs.each {|s| @parser.should parse(s) }
      end
    end
  end

  invalid_cases.each do |descr, strs|
    context(descr + ' (invalid)') do
      it 'should not parse' do
        strs.each {|s| @parser.should_not parse(s) }
      end
    end
  end
end
