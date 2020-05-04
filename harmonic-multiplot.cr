include Math
require "./mathvector.cr"
require "grlib"
include GR

def harmonic(x,k)
  [x[1], -k*x[0]].to_mathv
end
def euler(x,t,h,f)
  x+=h*f.call(x,t)
  t+=h
  {x,t}
end
def rk2(x,t,h,f)
  k1 = f.call(x,t)
  k2 = f.call(x+k1*h, t+h)
  {x + h/2*(k1+k2), t+h}
end

def rk4(x,t,h,f)
  hhalf=h/2
  k1 = f.call(x,t)
  k2 = f.call(x+k1*hhalf, t+hhalf)
  k3 = f.call(x+k2*hhalf, t+hhalf)
  k4 = f.call(x+k3*h, t+h)
  {x + (h/6)*(k1+k2*2+k3*2+k4), t+h}
end

setwindow(3e-5, 7e-2, 1e-14, 1e-1)
setscale(3)
box(x_tick:100,y_tick:100,major_y:2,xlog: true, ylog: true)

["Euler", "RK2", "RK4"].each{|name|
  n=100
  print "Result for ", name, " method\n"
  ha=Array(Float64).new
  ea=Array(Float64).new
  10.times{
    h=1.0/n*PI
    t=0.0
    x=[1.0,0.0].to_mathv
    k=1.0
    f = -> (xx : MathVector(Float64), t : Float64){ harmonic(xx,k)}
    while t < PI*2 - h/2
      if name == "Euler"
        x, t = euler(x,t,h,f)
      elsif name == "RK2"
        x, t = rk2(x,t,h,f)
      else
        x, t = rk4(x,t,h,f)
      end
    end
    ex = x[0]-cos(t)
    ey = x[1]-sin(t)
    print "h= ", h, "  errors= ",ex,  " ", ey, "\n"
#    ha.push log(h)/log(10)
#    ea.push log((x[0]-cos(t)).abs)/log(10)
    ha.push h
    ea.push sqrt(ex*ex+ey*ey)
    n*=2
  }
  p! ha
  p! ea
  polyline(ha, ea)
}
setcharheight(0.04)
mathtex(0.5,0.07,"\\Delta t")
mathtex(0.02,0.5,"\\Delta x")
mathtex(0.4,0.72,"\\rm Euler")
mathtex(0.5,0.55,"\\rm RK2")
mathtex(0.6,0.25,"\\rm RK4")

c=gets
