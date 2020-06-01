require "clop"
require "./vector3.cr"
require "./nacsio.cr"
include Math

optionstr = <<-END

  Description: Plummer's Model Builder
  Long description:
    This program creates an N-body realization of Plummer's Model.

    Original Ruby code:
    (c) 2004, Piet Hut and Jun Makino; see ACS at www.artcompsi.org
    The algorithm used is described in Aarseth, S., Henon, M., & Wielen, R.,
    Astron. Astroph. 37, 183 (1974).

    Crystal Version (c) 2020- Jun Makino

  Short name:		-n
  Long name:            --n_particles
  Value type:           int
  Default value:        10
  Variable name:        n
  Description:          Number of particles
  Long description:
    Number of particles in a realization of Plummer's Model.
    Each particles is drawn at random from the Plummer distribution,
    and therefore there are no correlations between the particles.
    Standard Units are used in which G = M = 1 and E = -1/4, where

      G is the gravitational constant
      M is the total mass of the N-body system
      E is the total energy of the N-body system


  Short name:           -s
  Long name:            --seed
  Value type:           int
  Default value:        0
  Variable name:      seed
  Description:  pseudorandom number seed given
  Long description:
    Seed for the pseudorandom number generator.  If a seed is given with
    value zero, a preudorandom number is chosen as the value of the seed.
    The seed value used is echoed separately from the seed value given,
    to allow the possibility to repeat the creation of an N-body realization.

  Short name:           -Y
  Long name:            --yaml_io
  Value type:           bool
  Variable name:      use_nacsio
  Description:  use nacs io format (yaml based)
  Long description: use nacs io format (yaml based)
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
  def ekin                        # kinetic energy
    e = 0
    @body.each{|b| e += b.ekin}
    e
  end
  def epot                        # potential energy
    e = 0
    @body.each{|b| e += b.epot(@body)}
    e/2                           # pairwise potentials were counted twice
  end

  def adjust_center_of_mass
    m_com = @body.reduce(0.0){|s, b| s + b.mass}
    pos_com = @body.reduce(Vector3.new){|vec, b| vec + b.pos*b.mass}
    vel_com = @body.reduce(Vector3.new){|vec, b| vec + b.vel*b.mass}
    pos_com /= m_com
    vel_com /= m_com
    @body.each do |b|
      b.pos -= pos_com
      b.vel -= vel_com
    end
  end

  def adjust_units
    alpha = -epot / 0.5
    beta = ekin / 0.25
    @body.each do |b|
      b.pos *= alpha
      b.vel /= sqrt(beta)
    end
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

def spherical(r, ran)
  theta = acos(ran.rand(2.0)-1.0)
  phi = ran.rand(2*PI)
  Vector3.new( r * sin( theta ) * cos( phi ),
                     r * sin( theta ) * sin( phi ),
                     r * cos( theta ))
end  

def plummer_sample(r)
  b = Particle.new
  scalefactor = 16.0 / (3.0 * PI)
  radius = 1.0 / sqrt( r.rand ** (-2.0/3.0) - 1.0)
  b.pos = spherical(radius,r) / scalefactor
  x = 0.0
  y = 0.1
  while y > x*x*(1.0-x*x)**3.5
    x = r.rand
    y = r.rand(0.1)
  end
  velocity = x * sqrt(2.0) * ( 1.0 + radius*radius)**(-0.25)
  b.vel = spherical(velocity,r) * sqrt(scalefactor)
  b
end

if options.seed == 0
  r= Random.new
else
  r= Random.new(options.seed)
end
nb = NBody.new
options.n.times do |i|
  b = plummer_sample(r)
  b.mass = 1.0/options.n
  b.id = i
  nb.body.push(b)
end
nb.adjust_center_of_mass if options.n > 0
nb.adjust_units if options.n > 1 && options.n < 100000
if options.use_nacsio
  print CommandLog.new("Plummer model created").to_nacs
  nb.nacswrite
else
  nb.write
end

