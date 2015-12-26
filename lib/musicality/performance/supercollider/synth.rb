module Musicality
module SuperCollider

class Synth < Node
  attr_reader :id, :group, :server, :running, :freed


  def initialize server, group, synthdef_name, add_action, target_id, args
    raise ArgumentError unless ADD_ACTIONS.include?(add_action)
    super server, group
    send_msg(Message.new('/s_new', synthdef_name, id, 
      add_action, target_id, *args.to_a.flatten))
  end

  def self.after target, synthdef_name, args = {}
    raise ArgumentError unless target.is_a?(Node)
    new target.server, target.group, synthdef_name, ADD_AFTER, target.id, args
  end
  
  def self.before target, synthdef_name, args = {}
    raise ArgumentError unless target.is_a?(Node)
    new target.server, target.group, synthdef_name, ADD_BEFORE, target.id, args
  end
  
  def self.head target, synthdef_name, args = {}
    raise ArgumentError unless target.is_a?(Group)
    new target.server, target, synthdef_name, ADD_HEAD, target.id, args
  end
  
  def self.tail target, synthdef_name, args = {}
    raise ArgumentError unless target.is_a?(Group)
    new target.server, target, synthdef_name, ADD_TAIL, target.id, args
  end
  
  def self.replace target, synthdef_name, args = {}
    raise ArgumentError unless target.is_a?(Node)
    new target.server, target.group, synthdef_name, ADD_REPLACE, target.id, args
  end

end

end
end
