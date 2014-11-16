module Musicality

module_function
def pack_score score
  packing = score.pack
  packing["type"] = score.class.to_s
  return packing
end

def unpack_score packing
  type = Kernel.const_get(packing["type"])
  type.unpack(packing)
end

end