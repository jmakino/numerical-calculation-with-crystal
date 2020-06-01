require "grlib"
require "./integratorlib.cr"
require "./vector3.cr"
require "clop"
include Math
include GR

optionstr= <<-END
  Description: Test integrator for Kepker problem
  Long description:
    Test integrator for Kepker problem
    (c) 2020, Jun Makino

  Short name:           -n
  Long name:  		--nsteps
  Value type:		int
  Default value: 	20
  Variable name: 	n
  Description:		Number of steps per orbit
  Long description:     Number of steps per orbit                   

  Short name: 		-o
  Long name:  		--norbits
  Value type:		int
  Default value:	1
  Variable name:	norb
  Description:		Number of orbits
  Long description:     Number of orbits

  Short name:		-w
  Long name:  		--window-size
  Value type:  		float
  Variable name:	wsize
  Default value:	1
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

  Short name:		-g
  Long name:		--graphic-output
  Value type:	        bool
  Variable name:	gout
  Description:
    whether or not create graphic output (default:no)
  Long description:
    whether or not create graphic output (default:no)

  Short name:		-t
  Long name:		--integrator-type
  Value type:	        string
  Variable name:	itype
  Default value:	LF
  Description:
    integrator scheme. LF:leapflog, Y4:Yosida4
  Long description:
    integrator scheme. LF:leapflog, Y4:Yosida4
END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)

def kepler_acceleration(x,m)
  r2 = x*x
  r=sqrt(r2)
  mr3inv = m/(r*r2)
  -x*mr3inv
end
def energy(x,v,m)
  m*(-1.0/sqrt(x*x)+v*v/2)
end
  
m=1.0
ff = -> (xx : Vector3){ kepler_acceleration(xx,m)}
integrator = if options.itype=="LF"
               STDERR.print "Leap frog will be used\n"
               -> (xx : Vector3, vv : Vector3, h : Float64)
               { Integrators.leapfrog(xx,vv,h,ff)}
             else
               STDERR.print "Yoshida4 will be used\n"
               -> (xx : Vector3, vv : Vector3, h : Float64)
               { Integrators.yoshida4(xx,vv,h,ff)}
             end

h = 2*PI/options.n
t=0.0
x= Vector3.new(1.0+options.ecc,0.0,0.0)
v= Vector3.new(0.0,sqrt((1-options.ecc)/(1+options.ecc)),0.0)
if options.gout
  wsize=options.wsize
  setwindow(-wsize, wsize,-wsize, wsize)
  box
  setcharheight(0.05)
  mathtex(0.5, 0.06, "x")
  mathtex(0.06, 0.5, "y")
end
e0 = energy(x,v,m)
emax = 0.0
while t < options.norb*PI*2 - h/2
  xp=x
  x, v = integrator.call(x,v,h)
  polyline([xp[0], x[0]], [xp[1], x[1]]) if options.gout
  t+=h
  emax = {(energy(x,v,m)-e0).abs, emax}.max
end
p! -emax/e0
c=gets if options.gout

