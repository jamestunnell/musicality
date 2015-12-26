module Musicality
module SuperCollider

class Group < Node
  def initialize server, group, add_action, target_id, parallel
    raise ArgumentError unless ADD_ACTIONS.include?(add_action)
    super server, group

    send_msg(Message.new(parallel ? '/p_new' : '/g_new',
      id, add_action, target_id))
  end

  def self.default server, parallel = false
    new(server, nil, ADD_TAIL, 0, parallel)
  end

  def self.after target, parallel = false
    raise ArgumentError unless target.is_a?(Node)
    new target.server, target.group, ADD_AFTER, target.id, parallel
  end
  
  def self.before target, parallel = false
    raise ArgumentError unless target.is_a?(Node)
    new target.server, target.group, ADD_BEFORE, target.id, parallel
  end
  
  def self.head target, parallel = false
    raise ArgumentError unless target.is_a?(Group)
    new target.server, target, ADD_HEAD, target.id, parallel
  end
  
  def self.tail target, parallel = false
    raise ArgumentError unless target.is_a?(Group)
    new target.server, target, ADD_TAIL, target.id, parallel
  end
    
  def self.replace target, parallel = false
    raise ArgumentError unless target.is_a?(Node)
    new target.server, target.group, ADD_REPLACE, target.id, parallel
  end

  def head node
    raise ArgumentError unless node.is_a?(Node)
    send_msg(Message.new('/g_head', id, node.id))
  end

  def tail node
    raise ArgumentError unless node.is_a?(Node)
    send_msg(Message.new('/g_tail', id, node.id))
  end

  def free_all
    send_msg(Message.new('/g_freeAll', id))
  end

  def deep_free
    send_msg(Message.new('/g_deepFree', id))
  end

  def dump_tree flag
    send_msg(Message.new('/g_dumpTree', id, flag ? 1 : 0))
  end

  def query_tree
    raise NotImplementedError
    # TODO
  end
end

end
end
