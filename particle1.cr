require "grlib"
require "clop"
require "./integratorlib.cr"
include Math
include GR

optionstr= <<-END
  Description: Test integrator  driver for Kepler problem
  Long description:
    Test integrator driver for Kepker problem
    (c) 2020, Jun Makino

  Short name:           -n
  Long name:  		--numner-of-particles
  Value type:		int
  Default value: 	2
  Variable name: 	n
  Description:		Number of particles
  Long description:     Number of particles

  Short name:           -s
  Long name:  		--softening
  Value type:		float
  Default value: 	0.0
  Variable name: 	eps
  Description:		Size of softening
  Long description:     Size of softening

  Short name:           -e
  Long name:  		--eccentricity
  Value type:		float
  Default value: 	0.0
  Variable name: 	ecc
  Description:		Eccentricity. Used only when n=2
  Long description:     Eccentricity. Used only when n=2

  Short name:           -d
  Long name:  		--step-size
  Value type:		float
  Default value: 	0.01
  Variable name: 	h
  Description:		Size of timestep
  Long description:     Size of timestep

  Short name: 		-T
  Long name:  		--end-time
  Value type:		int
  Default value:	1.0
  Value type:		float
  Variable name:	tend
  Description:		Time to stop integration
  Long description:     Time to stop integration

  Short name:		-w
  Long name:  		--window-size
  Value type:  		float
  Variable name:	wsize
  Default value:	1.5
  Description:		Window size for plotting
  Long description:
    Window size for plotting orbit. Window is [-wsize, wsize] for both of
    x and y coordinates

  Short name:		-e
  Long name:		--ecc
  Value type:		float
  Default value:	0.0
  Variable name:	ecc
  Description:		Initial eccentricity of the orbit
  Long description:     Initial eccentricity of the orbit


  Short name:		-v
  Long name:		--velocity-scale
  Value type:		float
  Default value:	0.5
  Variable name:	vscale
  Description:		Scaling factor for the initial velocity
  Long description:
    Scaling factor for the initial velocity.
    positions and velocities are set from random vectors within
    spheres of radius 1 and vscale.

END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)

require "./vector3.cr"
class Particle
  property :m, :x, :v, :acc, :phi
  def initialize(m : Float64=0, x : Vector3=Vector3.new(0,0,0),
                 v : Vector3=Vector3.new(0,0,0))
    @m = m; @x = x;  @v = v
    @acc = Vector3.new(0,0,0); @phi=0.0
  end
  def self.random(m, rx, rv)
    Particle.new(m.to_f, randomvector(rx), randomvector(rv))
  end
  def calc_gravity(p,eps2)
    dr = @x - p.x
    r2inv = 1.0/(dr*dr+eps2)
    rinv = sqrt(r2inv)
    r3inv = r2inv*rinv
    @phi -= p.m*rinv
    p.phi -= @m*rinv
    @acc -= p.m*r3inv*dr
    p.acc += @m*r3inv*dr
  end
end

class ParticleSystem
  property :particles, :eps2
  def initialize(eps2 : Float64 = 0.0 )
    @particles = Array(Particle).new
    @eps2 = eps2
  end
  def +(p : Particle)
    @particles.push p
    self
  end
  def self.random(n, rx, rv)
    ps=ParticleSystem.new
    m = 1.0/n
    n.times{ ps += Particle.random(m,rx,rv)}
    ps.adjust_cm
    ps
  end
  def self.twobody(x,v)
    ps=ParticleSystem.new
    n=2
    m = 1.0/n
    ps += Particle.new(m,x,v)
    ps += Particle.new(m,-x,-v)
    ps
  end
  def calc_accel
    @particles.each{|p|p.acc=Vector3.new; p.phi=0.0}
    @particles.each_with_index{|p,i|
      ((i+1)..(particles.size-1)).each{|j|
        p.calc_gravity(@particles[j], @eps2)
      }
    }
  end
  def inc_vel(h)
    @particles.each{|p|p.v += p.acc*(h)}
  end
  def inc_pos(h)
    @particles.each{|p|p.x += p.v*h}
  end
  def calc_cm
    sumx=Vector3.new
    sumv=Vector3.new
    summ=0.0
    @particles.each{|p|
      sumx += p.m*p.x
      sumv += p.m*p.v
      summ +=p.m
    }
    {sumx*(1/summ),sumv*(1/summ)}
  end
  def adjust_cm
    cmx,cmv = calc_cm
    @particles.each{|p|
      p.x -= cmx
      p.v -= cmv
    }
  end
end
  def randomvector(r)
    sqsum= r*r*2
    v=Vector3.new
    while sqsum > r*r
      v = Array.new(3){rand(r)*2-r}.to_v
      sqsum = v*v
    end
    v
  end


ENV["GKS_DOUBLE_BUF"]= "true" 

if options.n == 2
  ps = ParticleSystem.twobody([0.5*(1+options.ecc),0.0,0.0].to_v,
                              [0.0,0.5*sqrt((1-options.ecc)/(1+options.ecc)),0.0].to_v)
else
  ps =ParticleSystem.random(options.n,1.0,options.vscale)
end
ps.eps2= options.eps*options.eps
ps.calc_accel
wsize=options.wsize
setwindow(-wsize, wsize,-wsize, wsize)

time=0
while time < options.tend-options.h/2
#  SymplecticIntegrators.leapfrog(ps,options.h)
  SymplecticIntegrators.yoshida4(ps,options.h)
  time += options.h
  clearws() 
  box
  setcharheight(0.05)
  mathtex(0.5, 0.06, "x")
  mathtex(0.06, 0.5, "y")
  text(0.6,0.91,"t="+sprintf("%.3f",time))
  setmarkertype(4)
  setmarkersize(1)
  polymarker(ps.particles.map{|p| p.x[0]}, ps.particles.map{|p| p.x[1]})
  updatews() 
end
c=gets 

