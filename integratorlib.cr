#
# integrator library
#
module Integrators
  extend self
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
    {x + (k1+k2*2.0+k3*2.0+k4)*(h/6), t+h}
  end

  NITER = 5
  def gauss4(x, t, h, f)
    f1 =  f.call(x,t)
    f2 = f1
    a11 = 0.25
    a12 = 0.25 - sqrt(3.0)/6
    a21 = 0.25 + sqrt(3.0)/6
    a22 = 0.25
    t1 = t+(a11+a12)*h
    t2 = t+(a21+a22)*h
    NITER.times{
	xg1 = x+(a11*f1+a12*f2)*h
	xg2 = x+(a21*f1+a22*f2)*h
	f1 = f.call(xg1,t1)
	f2 = f.call(xg2,t2)
    }
    { x+(f1+f2)*0.5*h, t+h}
  end
  
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

  D1 = 1.0 / (2-exp(log(2.0)/3))
  D2 = 1 - 2*D1
  def yoshida4(x,v,h,f)
    x,v= leapfrog(x,v,h*D1,f)
    x,v= leapfrog(x,v,h*D2,f)
    leapfrog(x,v,h*D1,f)
  end

  def  yoshida6(x,v,h,f)
    d = {0.784513610477560, 0.235573213359357,
         -1.17767998417887, 1.31518632068391};
    4.times{|i|x,v = leapfrog(x,v,h*d[i],f)}
    3.times{|i|x,v = leapfrog(x,v,h*d[2-i],f)}
    {x,v}
  end


end

module SymplecticIntegrators
  extend self
  def leapfrog(s, h)
    s.inc_vel(h*0.5)
    s.inc_pos(h)
    s.calc_accel
    s.inc_vel(h*0.5)
  end
  D1 = 1.0 / (2-exp(log(2.0)/3))
  D2 = 1 - 2*D1
  def yoshida4(s,h)
    leapfrog(s,h*D1)
    leapfrog(s,h*D2)
    leapfrog(s,h*D1)
  end
  
  def  yoshida6(x,v,h,f)
    d = {0.784513610477560, 0.235573213359357,
         -1.17767998417887, 1.31518632068391};
    4.times{|i|leapfrog(s,h*d[i])}
    3.times{|i|leapfrog(s,h*d[2-i])}
  end
end

