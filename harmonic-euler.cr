#!/usr/bin/env crystal
include Math
x=1.0; v=0.0; k=1.0
h=ARGV[0].to_f*PI
p! h
t=0
while t< PI*2 - h/2
  dv = -x*k*h
  x+= v*h
  v+= dv
  t+= h
end
p! [x, v, t]
p! [x-cos(t), v-sin(t)]
