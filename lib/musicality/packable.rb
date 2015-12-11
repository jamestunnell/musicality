# Requires that an including class can be instantiated entirely by keyword 
# args that map these symbols to values
module Packable
  PACKED_CLASS_KEY = :packed_class

  def self.included(base)
    base.extend(ClassMethods)
    base.class_variable_set(:@@special_packing, {})
    base.class_variable_set(:@@special_unpacking, {})
  end

  module ClassMethods
    def unpack packing
      args = []
      kwargs = {}

      init_params.each do |name,type|
        if (type == :req || type == :keyreq) && !packing.has_key?(name)
          raise ArgumentError, "Packing does not have required key #{name}"
        end

        val = packing[name]
        if type == :keyrest
          raise "Expected this to be a Hash" unless val.is_a? Hash
        end

        val2 = if unpacks_specially?(name)
          unpack_specially(name,val)
        else
          Packable.unpack_val(val)
        end

        case type
        when :req, :opt
          args.push val2
        when :key, :keyreq
          kwargs[name] = val2
        when :keyrest
          kwargs.merge!(val2)
        end
      end
      
      if args.any?
        if kwargs.any?
          obj = new(*args,**kwargs)
        else
          obj = new(*args)
        end
      elsif kwargs.any?
        obj = new(**kwargs)
      else
        obj = new
      end

      block_given? ? yield(obj) : obj
    end

    def init_params
      params = instance_method(:initialize).parameters
      Hash[ params.map {|pair| pair.reverse } ]
    end
    
    def special_packing sym, &block
      class_variable_get(:@@special_packing)[sym] = block
    end

    def special_unpacking sym, &block
      class_variable_get(:@@special_unpacking)[sym] = block
    end
    
    def packs_specially? sym
      class_variable_get(:@@special_packing).has_key?(sym)
    end

    def unpacks_specially? sym
      class_variable_get(:@@special_unpacking).has_key?(sym)
    end

    def pack_specially sym, val
      class_variable_get(:@@special_packing)[sym].call(val)
    end

    def unpack_specially sym, val
      class_variable_get(:@@special_unpacking)[sym].call(val)
    end
  end

  def init_params
    self.class.init_params
  end
  
  def class_str
    self.class.to_s
  end

  def pack
    packing = { PACKED_CLASS_KEY => class_str }
    init_params.keys.each do |name|
      val = self.send(name)
      val2 = if self.class.packs_specially?(name)
        self.class.pack_specially(name,val)
      else
        Packable.pack_val(val)
      end
      packing[name] = val2
    end
    packing
  end

  def recover_class klass_str
    Kernel.const_get(klass_str)
  end
  module_function :recover_class

  private

  def unpack_val val
    if val.is_a? Array
      val.map {|v| Packable.unpack_val v}
    elsif val.is_a? Hash
      if val.packed_class?
        val.unpack
      else
        Hash[ val.map {|k,v| [ Packable.unpack_val(k), Packable.unpack_val(v) ]} ]
      end
    else
      val
    end
  end
  module_function :unpack_val

  def pack_val val
    if val.is_a?(Packable)
      val.pack
    elsif val.is_a? Array
      val.map {|v| pack_val v}
    elsif val.is_a? Hash
      Hash[ val.map {|k,v| [ Packable.pack_val(k), Packable.pack_val(v) ]} ]
    else
      val
    end
  end
  module_function :pack_val  
end

class Hash
  def packed_class?
    has_key?(Packable::PACKED_CLASS_KEY) && 
      Packable.recover_class(fetch(Packable::PACKED_CLASS_KEY)).included_modules.include?(Packable)
  end

  def unpack
    raise "Not a packed class" unless packed_class?
    Packable.recover_class(fetch(Packable::PACKED_CLASS_KEY)).unpack self
  end
end
