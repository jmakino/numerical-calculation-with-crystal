require "clop"
include Math
require "./nacsio.cr"
include Nacsio

optionstr = <<-END
  Description: First very simple version of Barnes-Hut tree code
  Long description:
    First very simple version of Barnes-Hut tree code
    Crystal version - (c) 2020- Jun Makino
    Original Ruby version - 
    (c) 2005, Piet Hut and Jun Makino. see ACS at www.artcompsi.org
    example
    hackcode1 < cube1.in

  Short name: 		-T
  Long name:		--opening_tolerance
  Value type:		float
  Default value: 	0.5
  Variable name: 	tol
  Description:		Opening tolerance
  Long description:
    This option sets the tolerance value that governs the maximum size
    of a tree cell that can remain closed; cells (nodes) with a size
    large than the product of tolerance and distance to that cell will
    be opened, and acceleration to its children will be computed.

  Short name: 		-s
  Long name:		--softening_length
  Value type:		float
  Default value: 	0.05
  Variable name: 	eps
  Description:		Softening length
  Long description:
    This option sets the softening length used to calculate the force
    between two particles.  The calculation scheme comforms to standard
    Plummer softening, where rs2=r**2+eps**2 is used in place of r**2.

  Short name: 		-c
  Long name:		--step_size
  Value type:		float
  Default value:	0.0078125
  Variable name:	dt
  Description:		Time step size
  Long description:
    This option sets the size of the time step, which is constant and
    shared by all particles.  It is wise to use option -s to specify a
    softening length that is significantly larger than the time step size.


  Short name: 		-d
  Long name:		--diagnostics_interval
  Value type:		float
  Default value:	0.25
  Variable name:	dt_dia
  Description:		Interval between diagnostics output
  Long description:
    The time interval between successive diagnostics output.
    The diagnostics include the kinetic and potential energy,
    and the absolute and relative drift of total energy, since
    the beginning of the integration.
        These diagnostics appear on the standard error stream.
    For more diagnostics, try option "-x" or "--extra_diagnostics".

  Short name: 		-o
  Long name:		--output_interval
  Value type:		float
  Default value:	2
  Variable name:	dt_out
  Description:		Time interval between snapshot output
  Long description:
    The time interval between output of a complete snapshot
    A snapshot of an N-body system contains the values of the
    mass, position, and velocity for each of the N particles.

  Short name: 		-t
  Long name:		--duration
  Value type:		float
  Default value:	1
  Variable name:	dt_end
  Description:		Duration of the integration
  Long description:
    This option sets the duration t of the integration, the time period
    after which the integration will halt.  If the initial snapshot is
    marked to be at time t_init, the integration will halt at time
    t_final = t_init + t.

  Short name:		-i
  Long name:  		--init_out
  Value type:  		bool
  Variable name: 	init_out
  Description:		Output the initial snapshot
  Long description:
    If this flag is set to true, the initial snapshot will be output
    on the standard output channel, before integration is started.

  Short name:		-x
  Long name:  		--extra_diagnostics
  Value type:  		bool
  Variable name:	x_flag

  Description:		Extra diagnostics
  Long description:
    If this flag is set to true, the following extra diagnostics
    will be printed;
      acceleration (for all integrators)
END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)

struct AccPot
  property :a, :p
  def initialize(a : Vector3 = Vector3.new, p : Float64 = 0.0)
    @a=a; @p=p
  end
  def +(other : AccPot)
    AccPot.new(@a+other.a, @p+other.p)
  end
end
  
class Body

  YAML.mapping(
    id: {type: Int64, default: 0i64,},
    time: {type: Float64, key: "t", default: 0.0,},
    mass: {type: Float64, key: "m",default: 0.0,},
    pos: {type: Vector3, key: "r",default: [0.0,0.0,0.0].to_v,},
    vel: {type: Vector3, key: "v",default: [0.0,0.0,0.0].to_v,},
    acc: {type: Vector3, key: "a",default: [0.0,0.0,0.0].to_v,},
    pot: {type: Float64, default: 0.0,},
  )  

  def get_other_acc_and_pot( other, eps)
    return AccPot.new if self == other
    rji = @pos  - other.pos 
    r2 = eps * eps + rji * rji
    rinv = 1.0/sqrt(r2)
    AccPot.new(@mass * rji*rinv*rinv*rinv, -@mass *rinv)
  end

  def ekin                         # kinetic energy
    0.5*@mass*(@vel*@vel)
  end

  def get_node_acc_and_pot(other, tol, eps)
    get_other_acc_and_pot(other, eps)
  end

  def loadtree(b)  exit  end

  def center_of_mass
    @pos
  end

end

class NBody
  property :time, :body, :rootnode, :ybody

  def initialize(time = 0.0)
    @body = Array(Body).new
    @ybody= Array(YAML::Any).new
    @time = time
    @eps = 0.0
    @e0=0.0
    @dt=0.015625
    @rootnode = Node.new([0.0,0.0,0.0].to_v, 1.0)
    @tol = 0.0
    @nsteps = 0
  end

  def evolve(tol : Float64,
             eps : Float64,
             dt : Float64, dt_dia : Float64,
	     dt_out : Float64, dt_end  : Float64,
	     init_out, x_flag)
    @dt = dt
    @tol = tol
    @eps = eps
    @nsteps = 0
    get_tree_acc
    e_init
    write_diagnostics(x_flag)
    t_dia = dt_dia - 0.5*dt
    t_out = dt_out - 0.5*dt
    t_end = dt_end - 0.5*dt
    write if init_out
    while @time < t_end
      leapfrog
      @time += @dt
      @nsteps += 1
      if @time >= t_dia
        write_diagnostics(x_flag)
        t_dia += dt_dia
      end
      if @time >= t_out
        write
        t_out += dt_out
      end
    end
  end

  def leapfrog
    @body.each do |b|
      b.vel += b.acc*0.5*@dt
      b.pos += b.vel*@dt
    end
    get_tree_acc
    @body.each do |b|
      b.vel += b.acc*0.5*@dt
    end
  end

  def get_tree_acc
    maketree
    @rootnode.center_of_mass
    @body.each{|b|
      #      b.acc = @rootnode.get_node_acc(b, @tol, @eps)
      ap= @rootnode.get_node_acc_and_pot(b, @tol, @eps)
      b.acc=ap.a
      b.pot = ap.p
    }
  end

  def ekin                        # kinetic energy
    e = 0.0
    @body.each{|b| e += b.ekin}
    e
  end

  def epot                        # potential energy
    e = 0.0
    @body.each{|b| e += b.pot*b.mass}
    e/2                           # pairwise potentials were counted twice
  end

  def e_init                      # initial total energy
    @e0 = ekin + epot
  end
  
  def write_diagnostics(x_flag)
    etot = ekin + epot
    STDERR.print <<-EOF
at time t = #{sprintf("%g", time)}, after #{@nsteps} steps :
  e_kin = #{sprintf("%.3g", ekin)}, \
 e_pot =  #{sprintf("%.3g", epot)}, \
 e_tot = #{sprintf("%.3g", etot)}
             e_tot - e_init = #{sprintf("%.3g", etot - @e0)}
  (e_tot - e_init) / e_init = #{sprintf("%.3g", (etot - @e0)/@e0 )}\n
EOF
    
    if x_flag
      STDERR.print "  for debugging purposes, here is the internal data ",
                   "representation:\n"
      pp! self
    end
  end

  def write
    @body.size.times{|i|
      @body[i].time = @time
      CP.new(@body[i], @ybody[i]).print_particle
    }
  end
  def read
    update_commandlog
    while (sp= CP(Body).read_particle).y != nil
      @body.push sp.p
      @ybody.push sp.y
    end
    @time = @body[0].time
  end

  def makerootnode : Node
    r = @body.reduce(0){|oldmax, b| [oldmax, b.pos.to_a.map{|x| x.abs}.max].max}
    s = 1.0
    while r > s
        s *= 2
    end  
    Node.new([0.0, 0.0, 0.0].to_v, s)
  end
  def maketree
    @rootnode = self.makerootnode
    i=0
    @body.each do |b|
#      print "loading body #{i} #{b.pos}\n"
      @rootnode.loadtree(b)
      i+=1
    end
  end

end

class Node
  property :mass, :pos

  def initialize(center : Vector3, size : Float64)
    @child = Array(Node|Body|Nil).new(8,nil)
    @pos = Vector3.new
    @mass=0.0
    @center, @size = center, size
  end

  def get_other_acc_and_pot( other, eps)
    return AccPot.new if self == other
    rji = @pos  - other.pos 
    r2 = eps * eps + rji * rji
    rinv = 1.0/sqrt(r2)
    AccPot.new(@mass * rji*rinv*rinv*rinv, -@mass *rinv)
  end

  def octant(pos)
    result = 0
    p=pos.to_a
    c=@center.to_a
    p.each_index do |i| 
      result *= 2
      result += 1 if p[i] > c[i]
    end
    result
  end

  def loadtree(b : Node)
  end
  def loadtree(b : Nil)
  end
  def loadtree(b : Body)
    corner = octant(b.pos)
    c=@child[corner]
    unless c
      @child[corner] = b
    else
      if @child[corner].class == Body
        tmp_b = @child[corner]
        child_size = @size / 2.0
        c = Node.new(@center + child_size*offset(corner),child_size)
        c.loadtree(tmp_b)
        @child[corner]=c
      end
      c.loadtree(b)
    end
  end

  def offset(corner)
    r=[] of Float64
    3.times{ r.unshift( ((corner & 1)*2 - 1 )+0.0) ; corner>>=1 }
    r.to_v
  end

  def check_body_in_cell
    @child.each do |c|
      if c.class == Body
        (c.pos - @center).each do |x|
          raise("\nbody out of cell:\n#{c.to_s}\n") if x.abs > @size
        end
      elsif c.class == Node
        c.check_body_in_cell
      end
    end
  end

  def center_of_mass
    @mass = 0.0
    @pos = [0.0, 0.0, 0.0].to_v
    @child.each do |c|
      if c
        c.center_of_mass if c.class == Node
        @mass += c.mass
        @pos += c.mass * c.pos
      end
    end
    @pos /= @mass
  end

  def get_node_acc_and_pot(b, tol, eps)
    distance = b.pos - @pos
    if 2 * @size > tol * sqrt(distance*distance)
      ap = AccPot.new
      @child.each{|c| ap += c.get_node_acc_and_pot(b, tol, eps)  if c }
      ap
    else
      self.get_other_acc_and_pot(b, eps)
    end
  end

end

nb = NBody.new
nb.read
STDERR.print "after nb.read\n"
nb.evolve(options.tol, options.eps, options.dt,options.dt_dia,
          options.dt_out, options.dt_end, options.init_out, options.x_flag)
