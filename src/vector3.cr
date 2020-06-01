require "yaml"
struct Vector3
  property :x, :y, :z
  def initialize(x : Float64 =0,  y : Float64 =0,  z : Float64 =0)
    @x=x; @y=y; @z=z
  end

  def +(a) Vector3.new(@x+a.x, @y+a.y, @z+a.z) end
  def -(a) Vector3.new(@x-a.x, @y-a.y, @z-a.z) end
  def -()  Vector3.new(-@x, -@y, -@z)  end
  def +()  self  end
  def *(a : Vector3) @x*a.x+ @y*a.y+ @z*a.z end    # inner product
  def *(a : Float) Vector3.new(@x*a, @y*a, @z*a)  end
  def /(a : Float) Vector3.new(@x/a, @y/a, @z/a)  end
  def cross(other)                   # outer product
    Vector3.new(@y*other.z - @z*other.y,
               @z*other.x - @x*other.z,
               @x*other.y - @y*other.x)
  end
  def sqr() self*self end
  def to_a() [@x, @y, @z] end
  macro method_missing(call)
    to_a.{{call}}
  end
  def self.zero()
    Vector3.new
  end
  def to_a()
    [@x, @y, @z]
  end
end

class Array
  def to_v() Vector3.new(self[0],self[1],self[2])  end
end

struct Float
  def *(a : Vector3) a*self end
end
