require "./vector3.cr"
Vector=Vector3
a=Vector.new(1,2,3)
b=Vector.new(1,1,1)
c=Vector.new(2,1)
d=Vector.new(y:1)

p a+b+c+d, a*b, c*d
p! a+b+c+d, a*b, c*d

