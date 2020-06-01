include Math
x=1.0; v=0.0; k=1.0
n=ARGV[0].to_i
h = 2*PI/n
p! h
t=0
n.times{
  dv = -x*k*h
  x+= v*h
  v+= dv
  t+= h
}
p! [x, v, t]
p! [x-cos(t), v-sin(t)]
