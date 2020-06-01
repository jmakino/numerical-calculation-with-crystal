#
# polynomial handling library 
# Copyright 2020- Jun Makino
#
class Polynomial(T) < Array(T)
  def Polynomial.zero
    [T.zero].to_poly
  end
  def extended(i)
    (i < self.size) ? self[i] : T.zero
  end
  def +(a)
    newsize = {self.size, a.size}.max
    newp=(0..(newsize-1)).map{|k|  self.extended(k)+ a.extended(k)}
    while newp[(newp.size) -1] == T.zero
      newp.pop
    end
    newp.to_poly
  end
  def -() self.map{|x| -x}.to_poly  end
  def -(a) self + (-a) end
  def +() self end
  def *(a)
    newp = Array.new(self.size+a.size-1){T.zero}
    self.size.times{|i|
      a.size.times{|j|
        newp[i+j] += self[i]* a[j]
      }
    }
    newp.to_poly
  end
  def ^(n : Int)
    newp=self
    (n-1).times{newp *= self}
    newp
  end
  def differentiate
    newp= self.map_with_index{|x,k| x*k}
    newp.shift
    newp.to_poly
  end
  def integrate
    ([T.zero] +  self.map_with_index{|x,k| x/(k+1)}).to_poly
  end
  def evaluate(x)
    self.reverse.reduce{|p,a| p = p*x+a}
  end
end
class Array(T)
  def to_poly
    x=Polynomial(T).new
    self.each{|v| x.push v}
    x
  end
end
