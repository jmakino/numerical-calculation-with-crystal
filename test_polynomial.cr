#
# test_polynomial.cr
#
require "./polynomial.cr"
require "grlib"
include GR

poly=[1,1].to_poly
pp! poly
pp! poly+poly
pp! poly - [1,1,1].to_poly
pp! poly*poly*poly
pp! ([1,1].to_poly)^10
pp! ([0.1,0.1].to_poly)^10
pp! ([1,1].to_poly)^5
pp! (([1,1].to_poly)^5).differentiate
pp! (([1.0,1.0].to_poly)^5).integrate
base= [1.0,-1.0].to_poly*[0.0,1.0].to_poly
pp! base
pp! (base^3).integrate
pp! [1.0,2.0,1.0].to_poly.evaluate(1.0)
pp! [1.0,2.0,1.0].to_poly.evaluate(2.0)
pp! [1.0,2.0,1.0].to_poly.evaluate(0.5)
a = [1.0,2.0,1.0].to_poly
b = [a,a].to_poly
pp! a
pp! b

def create_switch_function(order, rin : Float64, rout : Float64)
  poly= (([1.0,-1.0].to_poly*[0.0,1.0].to_poly)^order).integrate
  normalization = 1.0/poly.evaluate(1.0)
  scale = 1.0/(rout-rin)
  -> (x : Float64){
    if x > rout
      1.0
    elsif x < rin
      0.0
    else
      poly.evaluate((x-rin)*scale)*normalization
    end
  }
end

f5 = create_switch_function(5,0.5,1)
11.times{|i| pp! f5.call(i*0.1)}

setwindow(-0.2,1.2,-0.2,1.2)
box
setcharheight(0.05)
mathtex(0.5, 0.06, "x")
mathtex(0.03, 0.5, "K(x)")
x = Array.new(100){|i| 1.4*i/100 -0.2}
polyline(x, x.map{|v| f5.call(v)})
