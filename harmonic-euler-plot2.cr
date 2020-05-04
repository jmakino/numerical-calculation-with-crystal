require "grlib"
include Math
include GR
x=1.0; v=0.0; k=1.0
n=ARGV[0].to_i
norb=ARGV[1].to_i
wsize=ARGV[2].to_f
h = 2*PI/n
p! h
t=0
setwindow(-wsize, wsize,-wsize, wsize)
box
setcharheight(0.05)
mathtex(0.5, 0.06, "x")
mathtex(0.06, 0.5, "v")

(n*norb).times{
  xp=x
  vp=v
  dv = -x*k*h
  x+= v*h
  v+= dv
  t+= h
  GR.polyline([xp,x], [vp,v])
}
p! [x, v, t]
p! [x-cos(t), v-sin(t)]
gets
