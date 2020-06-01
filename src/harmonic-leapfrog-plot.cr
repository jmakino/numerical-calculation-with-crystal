require "grlib"
include Math
include GR
n=ARGV[0].to_i
norb=ARGV[1].to_i
wsize=ARGV[2].to_f
h = 2*PI/n
p! h
setwindow(0, norb,-wsize, wsize)
box
setcharheight(0.05)
mathtex(0.5, 0.06, "t/2\\pi")
mathtex(0.06, 0.5, "err")

def symplectic1(x,v,t,k,h)
  x+= v*h
  v+=  -x*k*h
  t+= h
  {x,v,t}
end
def symplectic2(x,v,t,k,h)
  v+=  -x*k*h
  x+= v*h
  t+= h
  {x,v,t}
end

def symplectic2(x,v,t,k,h)
  v+=  -x*k*h
  x+= v*h
  t+= h
  {x,v,t}
end

def leapfrog(x,v,t,k,h)
  f0 = -x*k
  x+= v*h + f0*(h*h/2)
  f1 = -x*k
  v+= (f0+f1)*(h/2)
  t+= h
  {x,v,t}
end

3.times{|i|
  x=1.0; v=0.0; k=1.0; t=0.0
  xdata=[0.0]
  ydata= [x-cos(t)]
  (n*norb).times{
    if i==0
      x,v,t=symplectic1(x,v,t,k,h)
    elsif i==1
      x,v,t=symplectic2(x,v,t,k,h)
    else
      x,v,t=leapfrog(x,v,t,k,h)
    end
    xdata.push t/(2*PI)
    ydata.push x-cos(t)
  }
  polyline(xdata, ydata)
  setlinetype(i+2)
}
gets
