#
# splitintegrator2.cr
# looks better than splitintegrator.cr but not working (doesn't compile)
#

require "grlib"
require "./integratorlib.cr"
require "./vector3.cr"
require "./mathvector.cr"
require "./polynomial.cr"
require "clop"
include Math
include GR

optionstr= <<-END
  Description: Test integrator for Kepker problem with split integrator
  Long description:
    Test integrator for Kepker problem with split integrator
    (c) 2020, Jun Makino

  Short name:           -s
  Long name:  		--soft-step
  Value type:		float
  Default value: 	0.1
  Variable name: 	h
  Description:		timestep for leapfrog part
  Long description:     timestep for leapfrog part

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


  Short name:		-E
  Long name:		--plot-energy-error
  Value type:	        bool
  Variable name:	eplot
  Description:
    plot de instead of orbit
  Long description:
    plot de instead of orbit

  Short name:		-r
  Long name:		--outer-cutoff-radius
  Value type:	        float
  Variable name:	rout
  Default value:	0.5
  Description:          outer cutoff radius for splitting
  Long description:     outer cutoff radius for splitting


  Short name:		-p
  Long name:		--cutoff-order
  Value type:	        int
  Variable name:	cutoff_order
  Default value:	4
  Description:          Smoothness order for the cutoff function
  Long description:     Smoothness order for the cutoff function

  Short name:		-q
  Long name:		--accuracy-parameter
  Value type:	        float
  Variable name:	eta
  Default value:	0.1
  Description:          Parameter for timestep criterion for hard part
  Long description:     Parameter for timestep criterion for hard part

  Short name:		-i
  Long name:		--integration-scheme
  Value type:	        string
  Variable name:	scheme
  Default value:	rk4
  Description:          Integration scheme
  Long description:
    Integration scheme. Currently rk2 and rk4 are supported


  Short name:		-v
  Long name:		--debug-lebel
  Value type:	        int
  Variable name:	debug_level
  Default value:	0
  Description:          debug level
  Long description:     debug level

END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)

def variable_step_rk4(x,v,h,g,q)
  t=0.0
  ff =  ->(x : MathVector(Vector3), t : Float64){ [x[1], g.call(x[0])].to_mathv} 
  while t < h
    dt = sqrt((x*x)/(v*v))*q
    dt = h-t if t+dt > h
    xv = [x,v].to_mathv
    xv,t = Integrators.rk4(xv,t,dt,ff)    
    x,v= xv
  end
  {x,v}
end

def variable_step_int(x,v,h,g,q,fint)
  t=0.0
  ff =  ->(x : MathVector(Vector3), t : Float64){ [x[1], g.call(x[0])].to_mathv} 
  while t < h
    dt = sqrt((x*x)/(v*v))*q
    dt = h-t if t+dt > h
    xv = [x,v].to_mathv
    pp!  dt
    pp! xv
    pp! ff.call(xv,t)
    pp! g.call(x)
    xv,t = fint.call(xv,t,dt,ff)    
    x,v= xv
  end
  {x,v}
end

def hybrid(x,v,h,f,g,q, fint)
  f0 = f.call(x)
  v+= f0*(h/2)
  pp! [x, v, f0]
  x,v = variable_step_int(x,v,h,g,q, fint)
  pp! [x, v]
  f1 = f.call(x)
  pp! [x, v, f1]
  v+= f1*(h/2)
  pp! [x, v, f1]
  {x,v}
end

def kepler_acceleration(x,m)
  r2 = x*x
  r=sqrt(r2)
  mr3inv = m/(r*r2)
  -x*mr3inv
end
def energy(x,v,m)
  m*(-1.0/sqrt(x*x)+v*v/2)
end

def create_switch_function(order, rin : Float64, rout : Float64)
  poly= (([1.0,-1.0].to_poly*[0.0,1.0].to_poly)^order).integrate
  normalization = 1.0/poly.evaluate(1.0)
  scale = 1.0/(rout-rin)
  -> (x : Float64){
    if x > rout
      1.0
    elsif x < rin
      0.0
    else
      poly.evaluate((x-rin)*scale)*normalization
    end
  }
end

m=1.0
switch= create_switch_function(options.cutoff_order,
                               options.rout*0.5,
                               options.rout)
fout =  -> (xx : Vector3){kepler_acceleration(xx,m)*switch.call(sqrt(xx*xx))}
fin=  -> (xx : Vector3){kepler_acceleration(xx,m)*(1-switch.call(sqrt(xx*xx)))}

fint =  ->(x : MathVector(Vector3), t : Float64, dt : Float64,
           ff : Proc( MathVector(Vector3), Float64, MathVector(Vector3))){
  Integrators.rk4(x,t,dt,ff)}
if options.scheme == "rk2"
fint =  ->(x : MathVector(Vector3), t : Float64, dt : Float64,
           ff : Proc( MathVector(Vector3), Float64, MathVector(Vector3))){
  Integrators.rk2(x,t,dt,ff)}
end
if options.scheme == "gauss4"
fint =  ->(x : MathVector(Vector3), t : Float64, dt : Float64,
           ff : Proc( MathVector(Vector3), Float64, MathVector(Vector3))){
  Integrators.gauss4(x,t,dt,ff)}
end
  
           
t=0.0
x= Vector3.new(1.0+options.ecc,0.0,0.0)
v= Vector3.new(0.0,sqrt((1-options.ecc)/(1+options.ecc)),0.0)
if options.gout
  wsize=options.wsize
  if options.eplot
    setwindow(0.0, options.norb*PI*2,-wsize, wsize)
  else
    setwindow(-wsize, wsize,-wsize, wsize)
  end
  box
  setcharheight(0.05)
  if options.eplot
    mathtex(0.5, 0.06, "t")
  mathtex(0.06, 0.5, "|de|")
  else
    mathtex(0.5, 0.06, "x")
    mathtex(0.06, 0.5, "y")
  end
end
e0 = energy(x,v,m)
emax = 0.0
de=0.0
while t < options.norb*PI*2 - options.h
  dep=de
  xp=x
  tp=t
  x, v = hybrid(x, v, options.h, fout, fin, options.eta, fint)
  t+=options.h
  de =energy(x,v,m)-e0
  pp! t, de if options.debug_level > 2
  emax = {de.abs, emax}.max
  if options.gout
    if options.eplot
      polyline([tp, t], [dep, de])
    else
      polyline([xp[0], x[0]], [xp[1], x[1]])
    end
  end
  pp! x, v, energy(x,v,m)
end
p! -emax/e0
c=gets if options.gout

