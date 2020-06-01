require "grlib"
include Math
include GR
def symplectic1a(x,v,h,f)
  x+= v*h
  v+=  f.call(x)*h
  {x,v}
end
def symplectic1b(x,v,h,f)
  v+=  f.call(x)*h
  x+= v*h
  {x,v}
end


def leapfrog(x,v,h,f)
  f0 = f.call(x)
  x+= v*h + f0*(h*h/2)
  f1 = f.call(x)
  v+= (f0+f1)*(h/2)
  {x,v}
end

def harmonic(x,k)
  -k*x
end


setwindow(3e-5, 7e-2, 1e-8, 1e-1)
setscale(3)
box(x_tick:100,y_tick:100,major_y:2,xlog: true, ylog: true)

k=1.0
ff = -> (xx : Float64){ harmonic(xx,k)}

lt=1
["S1A", "S1B", "LF"].each{|name|
  n=100
  print "Result for ", name, " method\n"
  ha=Array(Float64).new
  ea=Array(Float64).new
  10.times{
    h=1.0/n*PI
    t=0.0
    x=1.0
    v=0.0
    emax = 0.0
    h = 2*PI/n
    p! h
    while t < 10*PI*2 - h/2
      if name == "S1A"
        x, v = symplectic1a(x,v,h,ff)
      elsif name == "S1B"
        x, v = symplectic1b(x,v,h,ff)
      else
        x, v = leapfrog(x,v,h,ff)
      end
      t+= h
      ex = x-cos(t)
      ev = v+sin(t)
      eabs=sqrt(ex*ex+ev*ev)
      emax = eabs if eabs > emax
    end
    ha.push h
    ea.push emax
    n*=2
  }
  p! ha
  p! ea
  setlinetype(lt)
  polyline(ha, ea)
  lt+=1
}
setcharheight(0.04)
mathtex(0.5,0.07,"\\Delta t")
mathtex(0.02,0.5,"\\rm Err ")
mathtex(0.4,0.55,"\\rm S1A")
mathtex(0.5,0.75,"\\rm S1B")
mathtex(0.4,0.25,"\\rm Leapfrog")

c=gets
