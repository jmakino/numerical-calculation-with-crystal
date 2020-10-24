  class Narray_F64
    property :data
    def initialize(nx : Int32,ny : Int32 = 1)
      @data = Pointer(Float64).malloc(nx*ny)
      @nx=nx
      @ny=ny
    end
    def [](i)   @data[i] end
    def [](i,j) @data[i*@ny+j]  end
    def []=(i,x)  @data[i]=x    end
    def []=(i,j,x)   @data[i*@ny+j]=x  end
  end
