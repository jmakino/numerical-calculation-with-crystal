require "grlib"
require "clop"
include Math
include GR

optionstr= <<-END
  Description: Test integrator  driver for Kepler problem
  Long description:
    Test integrator driver for Kepker problem
    (c) 2020, Jun Makino

  Short name:           -n
  Long name:  		--nsteps-initial
  Value type:		int
  Default value: 	20
  Variable name: 	n
  Description:		Initial number of steps per orbit
  Long description:     Initial number of steps per orbit

  Short name: 		-o
  Long name:  		--norbits
  Value type:		int
  Default value:	10
  Variable name:	norb
  Description:		Number of orbits
  Long description:     Number of orbits

  Short name: 		-N
  Long name:  		--number-of trial-integrations
  Value type:		int
  Default value:	10
  Variable name:	ntry
  Description:		
  Long description:
    Number of trial integrations. The timestep is halved at each
    iteration

  Short name:		-e
  Long name:		--ecc
  Value type:		float vector
  Default value:	0.0,0.3
  Variable name:	ecc
  Description:		values of the eccentricity of the orbit
  Long description:     values of the eccentricity of the orbit

  Short name:		-y
  Long name:		--range-of-y
  Value type:		float vector
  Default value:	1e-15,1e-2
  Variable name:	yrange
  Description:		range of plot of y axis
  Long description:     range of plot of y axis

  Short name:		-t
  Long name:		--integrator-type
  Value type:	        string
  Variable name:	itype
  Default value:	LF
  Description:
    integrator scheme. LF:leapflog, Y4:Yosida4
  Long description:
    integrator scheme. LF:leapflog, Y4:Yosida4
END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)

n=options.n
system "make keplerplot3"
h0 = 2*PI/n
setwindow(h0/(1<<options.ntry), h0, options.yrange[0], options.yrange[1])
box(10,10, major_x:1, major_y:2, ylog: true, xlog: true)
setcharheight(0.04)     
mathtex(0.5, 0.06, "h")
mathtex(0.01, 0.5, "\\Delta E")
options.ecc.each{|ecc|
  hs=Array(Float64).new
  errs=Array(Float64).new
  n=options.n
  options.ntry.times{
    errs.push `keplerplot3 -n #{n} -e #{ecc} -o #{options.norb} -t #{options.itype}`.
                  split.last.to_f.abs
    hs.push 2*PI/n
    n*=2
    pp! hs
    pp! errs
  }
  polyline(hs, errs)
}
text(0.2,0.91,"ecc="+options.ecc.join(" ")+", "+options.itype)
c=gets

