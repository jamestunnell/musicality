module Musicality
module Dynamics
  PPP = 0.1
  FFF = 0.9
  DYNAMIC_RATIO = (FFF/PPP)**(1.0/7.0) # 7 ratios between the 8 dynamic levels

  PP = PPP*DYNAMIC_RATIO
  P = PP*DYNAMIC_RATIO
  MP = P*DYNAMIC_RATIO
  MF = MP*DYNAMIC_RATIO
  F = MF*DYNAMIC_RATIO
  FF = F*DYNAMIC_RATIO
  
end
end