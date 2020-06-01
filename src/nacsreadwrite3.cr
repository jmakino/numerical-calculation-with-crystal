# nacsreadwrite3.cr
#
# Test code for Basic YAML-based read/write for
# nacs (new art of computational science)

require "./nacsio.cr"
include Nacsio

class IDParticle
  YAML.mapping(
    id: {type: Int64, default: 0i64,},
  )  
end

update_commandlog

while (sp= CP(IDParticle).read_particle).y != nil
  p = sp.p
  p.id += 1
  sp.p = p
  sp.print_particle
end
