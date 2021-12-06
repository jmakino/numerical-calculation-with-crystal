require "clop"
require "./vector3.cr"
require "./nacsio.cr"
include Math

optionstr = <<-END

  Description: Read in nemo snapprint output and output nacs snapshot
  Long description:
    Read in nemo snapprint output and output nacs snapshot

  Short name:           -Y
  Long name:            --yaml_io
  Value type:           bool
  Variable name:      use_nacsio
  Description:  use nacs io format (yaml based)
  Long description: use nacs io format (yaml based)


  Short name:           -F
  Long name:            --fdps-input
  Value type:           bool
  Variable name:      fdps_input
  Description:  Input file is in FDPS default format
  Long description:
    Input file is in FDPS default format. This means the file has following
    structure:
    Time
    n
    id0 mass0 x0 y0 z0 vx0 vy0 vz0
    ...
    (n particles, one per line)

END
clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)

module Nacsio
class Particle
  def ekin                         # kinetic energy
    0.5*@mass*(@vel*@vel)
  end
  def epot(body_array)             # potential energy
    p = 0
    body_array.each{ |b|
      unless b == self
        r = b.pos - @pos
        p += -@mass*b.mass/sqrt(r*r)
      end
    }
    p
  end
  def write
    printf("%22.15e", @mass)
    @pos.to_a.each { |x| printf("%23.15e", x) }
    @vel.to_a.each { |x| printf("%23.15e", x) }
    print "\n"
  end
end
end

include Nacsio

class NBody

  property :time, :body
  def initialize
    @time = 0.0
    @body = Array(Particle).new
  end

  def write
    print @body.size, "\n"
    printf("%22.15e\n", @time)
    @body.each do |b| b.write end
  end
  def nacswrite
    @body.each{|b| print b.to_nacs}
  end

end

def read_particle(s, fdps_mode)
  b = Particle.new
  a = s.to_s.split
  if fdps_mode
    b.id = a[0].to_i64
    a.shift
  end
  a = a.map{|x| x.to_f}
  b.mass = a[0]
  b.pos = a[1..3].to_v
  b.vel = a[4..6].to_v
  b
#  pp! b
end

def read_snapshot(fdps_mode)
  nb = NBody.new
  i = 0i64
  n = 0i64
  eof_reached = false
  if fdps_mode
    s=gets("\n");
    if s == nil
      eof_reached = true
    else
      nb.time = s.to_s.to_f
      s=gets("\n");
      n= s.to_s.to_i64
      STDERR.print "Time=", nb.time, "\n"
    end
  end
  if !eof_reached
    while s=gets("\n")
      #  pp! s
      b = read_particle(s.to_s, fdps_mode)
      b.id = i unless fdps_mode
      b.time = nb.time if fdps_mode
      nb.body.push(b)
      i+=1
      break if i==n && n > 0
    end
  end
  nb=nil if eof_reached
  nb
end
  

first_time = true  
while nb=read_snapshot(options.fdps_input)
  if options.use_nacsio
    print CommandLog.new("readsnapprint").to_nacs if first_time
    nb.nacswrite
  else
    nb.write
  end
  first_time = false
end

