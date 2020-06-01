class Vector3
  property :x, :y, :z
  def initialize(x : Float64,  y : Float64,  z : Float64)
    @x=x; @y=y; @z=z
  end
  def +(a)
    Vector3.new(@x+a.x, @y+a.y, @z+a.z)
  end
end
x=Vector3.new(1,2,3)
p x
y=Vector3.new(1,1,1)
p y
z=x+y
p z
