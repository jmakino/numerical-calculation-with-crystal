# narray.cr
#
# multi-dimensional array similar to NUMO:Narray
#
# Copyright 2020- J. Makino
#
macro use_narray(bound_check = false)
class Narray(T)
  property :data
  def Narray.range_check?
    {% if bound_check %}
      true
    {% else %}
      false
    {% end %}
  end
  def initialize(nx : Int32,ny : Int32 = 1, nz : Int32 = 1)
    {% if bound_check %}
      @data = Slice(T).new(Pointer(T).malloc(nx*ny*nz), nx*ny*nz)
      @datasl = @data
    {% else %}
      @data = Pointer(T).malloc(nx*ny*nz)
      @datasl = Slice(T).new(@data,  nx*ny*nz)
    {% end %}
    @nx=nx
    @ny=ny
    @nz=nz
  end
  def [](i)   @data[i] end
  def [](i,j) @data[i*@ny+j]  end
  def [](i,j,k)     @data[(i*@ny+j)*@nz+k]   end
  def []=(i,x)  @data[i]=x    end
  def []=(i,j,x)   @data[i*@ny+j]=x  end
  def []=(i,j,k, x)  @data[(i*@ny+j)*@nz+k]=x   end
  macro method_missing(call)
    @datasl.\{{call}}
  end
end
end

{% if flag?(:range_check) %}                     
  use_narray(true)
    {% else %}
    use_narray(false)
{% end %}    
