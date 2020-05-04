include Math
require "./mathvector.cr"

def harmonic(x,k)
  [x[1], -k*x[0]].to_mathv
end
n=100
5.times{
  h=1.0/n*PI
  t=0.0
  x=[1.0,0.0].to_mathv
  k=1.0
  while t< PI*2 - h/2
    k1 = harmonic(x,k)
    k2 = harmonic(x+k1*h, k)
    x += h/2*(k1+k2)
    t+= h
  end
  print "h= ", h, "  errors= ",x[0]-cos(t),  " ", x[1]-sin(t), "\n"
  n*=10
}
