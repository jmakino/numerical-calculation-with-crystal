# nacsiotest0.cr
#
# Test code for Basic YAML-based IO library for
# nacs (new art of computational science)

require "./nacsio0.cr"
include Nacsio

print CommandLog.new("Sample log message").to_nacs
(0..2).each{|id|
  obj=Particle.new
  obj.id =id.to_i64 
  obj.pos[0]=id*0.1
  print obj.to_nacs
}
