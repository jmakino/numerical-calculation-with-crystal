require "grlib"
require "clop"
require "./nacsio.cr"
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
END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)
update_commandlog
ENV["GKS_DOUBLE_BUF"]= "true" 
  
wsize=options.wsize
setwindow(-wsize, wsize,-wsize, wsize)
setcharheight(0.05)
setmarkertype(4)
setmarkersize(1)
sp= CP(Particle).read_particle
while sp.y != nil
  pp=[sp.p]
  time = pp[0].time
  pp! time
  while (sp= CP(Particle).read_particle).y != nil && sp.p.time == time
    pp.push sp.p
  end
  clearws() 
  box
  mathtex(0.5, 0.06, "x")
  mathtex(0.06, 0.5, "y")
  text(0.6,0.91,"t="+sprintf("%.3f",pp[0].time))
  polymarker(pp.map{|p| p.pos[0]}, pp.map{|p| p.pos[1]})
  updatews()
end
c=STDERR.gets
