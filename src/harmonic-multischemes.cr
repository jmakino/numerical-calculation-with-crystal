include Math
require "./mathvector.cr"

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

["Euler", "RK2"].each{|name|
  n=100
  print "Result for ", name, " method\n"
  5.times{
    h=1.0/n*PI
    t=0.0
    x=[1.0,0.0].to_mathv
    k=1.0
    f = -> (xx : MathVector(Float64), t : Float64){ harmonic(xx,k)}
    while t < PI*2 - h/2
      if name == "Euler"
        x, t = euler(x,t,h,f)
      else
        x, t = rk2(x,t,h,f)
      end
    end
    print "h= ", h, "  errors= ",x[0]-cos(t),  " ", x[1]-sin(t), "\n"
    n*=10
  }
}
