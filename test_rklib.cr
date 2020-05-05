require "./rklib.cr"

ff = -> (x : Float64, t : Float64){-x }
h=0.1
10.times{
  x=1.0
  t=0.0
  while t < 1.0-h/2
    x,t = RungeKuttaIntegrators.rkf78(x,t,h,ff)
  end
  pp! [t,x, h, x - Math.exp(-1)]
  h /= 2
}

