require "grlib"
require "clop"
require "./nacsio.cr"
require "./parser.cr"
include Math
include GR
include Nacsio

optionstr= <<-END
  Description: Plot program for multiple nacs snapshot
  Long description: Plot program for multiple nacs snapshot

  Short name:		-w
  Long name:  		--window-size
  Value type:  		float
  Variable name:	wsize
  Default value:	1.5
  Description:		Window size for plotting
  Long description:
    Window size for plotting orbit. Window is [-wsize, wsize] for both of
    x and y coordinates

  Short name:		-x
  Long name:  		--x_expression
  Value type:  		string
  Variable name:	xexp
  Default value:	r[0]
  Description:		Expression to use as x coordinate
  Long description:     Expression to use as x coordinate

  Short name:		-y
  Long name:  		--y_expression
  Value type:  		string
  Variable name:	yexp
  Default value:	r[1]
  Description:		Expression to use as y coordinate
  Long description:     Expression to use as y coordinate

END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)
include NacsParser

pp! options

xexp = expression(scan_expression_string(options.xexp))
yexp = expression(scan_expression_string(options.yexp))

update_commandlog
ENV["GKS_DOUBLE_BUF"]= "true" 
  
wsize=options.wsize
setwindow(-wsize, wsize,-wsize, wsize)
setcharheight(0.05)
setmarkertype(4)
setmarkersize(1)
sp= CP(Particle).read_particle
while sp.y != nil
  pp=[sp.y]
  time = sp.p.time
  pp! time
  while (sp= CP(Particle).read_particle).y != nil && sp.p.time == time
    pp.push sp.y
  end
  clearws() 
  box
  mathtex(0.5, 0.06, "x")
  mathtex(0.06, 0.5, "y")
  text(0.6,0.91,"t="+sprintf("%.3f", time))
  polymarker(pp.map{|p| eval_expression(xexp,p)},
             pp.map{|p| eval_expression(yexp,p)})
  updatews()
end
c=STDERR.gets
