module Musicality
module SuperCollider

class Node
  def self.next_id
    @@next_id += 1
  end

  def self.reset_id_counter
    @@next_id = 999
  end
  reset_id_counter

  attr_reader :id, :group, :server, :running, :freed

  def initialize server, group
    raise ArgumentError unless (server.is_a?(Server) || server.nil?)
    raise ArgumentError unless (group.is_a?(Group) || group.nil?)
    @server, @group = server, group
    @id = Node.next_id
    @freed, @running = false, true
    @queue = []
  end

  def send_msg msg
    if @server.nil?
      @queue.push msg
    else
      @server.send_msg(msg)
    end
  end

  def bundle_queue time
    Bundle.new(time, *@queue.shift(@queue.size))
  end

  # def recv_msg
  #   @server.recv_msg
  # end

  # def wait_for_msg expected_response_addr
  #   @server.wait_for_msg(expected_response_addr)
  # end

  def free
    @group, @running, freed = nil, false, true
    send_msg(Message.new('/n_free', id))
  end
  
  def start
    run(true)
  end

  def stop
    run(false)
  end

  def set args = {}
    send_msg(Message.new('/n_set', @id, *args.to_a.flatten))
  end

  def setn args = {}
    ary = args.map {|idx_or_name, vals| [ idx_or_name, vals.size, vals ]}.flatten
    send_msg(Message.new('/n_setn', @id, *ary))
  end

  def fill idx_or_name, value, n
    send_msg(OSC:Message.new('/n_fill', @id, idx_or_name, n, value))
  end

  # def map
  # end

  # def mapn
  # end

  # def mapa
  # end

  # def mapan
  # end
  
  def before node
    @group = node.group
    send_msg(Message.new( '/n_before', @id, node.id))
  end
  
  def after node
    @group = node.group
    send_msg(Message.new( '/n_after', @id, node.id))
  end

  # def query
  #   notifying = @server.notifying
  #   unless notifying
  #     @server.start_notification
  #   end
  #   send_msg(OSC::Message.new('/n_query', @id))
  #   info = @server.await_notification '/n_info'
  #   if notifying
  #     @server.stop_notification
  #   end
  #   info
  # end

  def trace
    send_msg(Message.new( '/n_trace', @id))
  end

  # def order
  # end

  private

  def run flag
    @running = flag
    send_msg(Message.new( '/n_run', @id, flag ? 1 : 0))
  end
end

end
end