require "grlib"
require "./integratorlib.cr"
require "./vector3.cr"
include Math
include GR
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
integrator = if ARGV[3]=="LF"
               STDERR.print "Leap frog will be used\n"
               -> (xx : Vector3, vv : Vector3, h : Float64){ Integrators.leapfrog(xx,vv,h,ff)}
             else
               STDERR.print "Yoshida4 will be used\n"
               -> (xx : Vector3, vv : Vector3, h : Float64){ Integrators.yoshida4(xx,vv,h,ff)}
             end

n=ARGV[0].to_i
norb=ARGV[1].to_i
wsize=ARGV[2].to_f
h = 2*PI/n
t=0.0
x= Vector3.new(1.0,0.0,0.0)
v= Vector3.new(0.0,1.0,0.0)
setwindow(-wsize, wsize,-wsize, wsize)
box
setcharheight(0.05)
mathtex(0.5, 0.06, "x")
mathtex(0.06, 0.5, "y")
e0 = energy(x,v,m)
emax = 0.0
while t < norb*PI*2 - h/2
  xp=x
  x, v = integrator.call(x,v,h)
  polyline([xp[0], x[0]], [xp[1], x[1]])
  t+=h
  emax = {(energy(x,v,m)-e0).abs, emax}.max
end
p! -emax/e0
c=gets
