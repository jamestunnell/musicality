require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Optimization do
  describe '.linking' do
    context 'one unlinked, one untargeted' do
      it 'should map the one unlinked to the one untargeted' do
        [ C4, Bb4, G2, A3 ].each do |p1|
          [ C4, Bb4, G2, A3 ].each do |p2|
            sol = Optimization.linking([p1], [p2])
            sol.size.should eq 1
            sol.should have_key p1
            sol[p1].should eq p2
          end
        end
      end
    end
    
    context 'two unlinked, one untargeted' do
      it 'should map the closest unlinked to the one untargeted' do
        unlinked = [C4,G4]
        { [Bb4] => {G4 => Bb4},
          [F4] => {G4 => F4},
          [E4] => {G4 => E4},
          [Eb4] => {C4 => Eb4},
          [D4] => {C4 => D4},
          [Bb3] => {C4 => Bb3}
        }.each do |untargeted, expected_map|
          sol = Optimization.linking(unlinked, untargeted)
          sol.should eq expected_map
        end
      end
    end
    
    context 'one unlinked, two untargeted' do
      it 'should map the one unlinked to the closest untargeted' do
        unlinked = [C4]
        { [G4,Bb4] => {C4 => G4},
          [G4,F4] => {C4 => F4},
          [Eb4,D4] => {C4 => D4},
          [G4,Bb3] => {C4 => Bb3},
          [G3,G4] => {C4 => G3}
        }.each do |untargeted, expected_map|
          sol = Optimization.linking(unlinked, untargeted)
          sol.should eq expected_map
        end
      end
    end
    
    context 'many unlinked, many untargeted' do
      it 'should map [unlinked.size, untargeted.size].min unlinked to untargeted, such that total pitch diffs is minimized' do
        {
          [[A3,B3,C3],[B3,Db3]] => { B3 => B3, C3 => Db3 },
          [[A3,B3,C3],[Bb3,C3]] => { A3 => Bb3, C3 => C3 },
          [[A3,B3,C3],[Gb3,Bb3]] => { A3 => Gb3, B3 => Bb3 },
          [[D5,Gb5],[B5,E5,G5]] => { D5 => E5, Gb5 => G5 },
          [[D5,Gb5],[Db5,E5,G5]] => { D5 => Db5, Gb5 => G5 },
          [[D5,Gb5],[C5,E5,G5]] => { D5 => C5, Gb5 => G5 },
          [[D5,Gb5],[B5,E5,G5]] => { D5 => E5, Gb5 => G5 },
          [[D5,Gb5],[B5,E5,F5,G5]] => { D5 => E5, Gb5 => F5 },
          [[D5,Gb5],[B5,F5,G5]] => { D5 => F5, Gb5 => G5 },
          [[G5],[B5,F5,G5]] => { G5 => G5 },
          [[B5,F5,G5],[G5]] => { G5 => G5 },
          [[G5],[C5,A5,B5]] => { G5 => A5 },
          [[C4,E4,G4,Bb4],[D4,Gb4,A4,C5]] => { C4 => D4, E4 => Gb4, G4 => A4, Bb4 => C5 }
        }.each do |unlinked_untargeted, expected_map|
          unlinked,untargeted = unlinked_untargeted
          sol = Optimization.linking(unlinked, untargeted)
          sol.should eq expected_map
        end
      end
    end
  end
end
