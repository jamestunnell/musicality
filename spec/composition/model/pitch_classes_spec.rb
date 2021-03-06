require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

pc_syms = [:C, :Db, :D, :Eb, :E, :F, :Gb, :G, :Ab, :A, :Bb, :B]

describe PitchClasses do
  it 'should include pitch-class constants for C, Db, D, ...' do
    pc_syms.each do |sym|
      expect(PitchClasses.constants).to include(sym)
    end
  end
end


describe 'PITCH_CLASSES' do
  it 'should be in the Musicality module namespace' do
    expect(Musicality.constants).to include(:PITCH_CLASSES)
  end

  it 'should have each constant value in PitchClasses' do
    PitchClasses.constants.each do |sym|
      expect(PITCH_CLASSES).to include(PitchClasses.const_get(sym))
    end
  end
end
