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

  Short name:		-W
  Long name:  		--window-geometry
  Value type:  		float vector
  Variable name:	wbox
  Default value:	0.0,0.0,0.0,0.0
  Description:		Window geometry
  Long description:
    Window geometory xmin, xmax, ymin, ymax.
    wsize is used if wbox[0]==wbox[1]


  Short name:		-x
  Long name:  		--x_expression
  Value type:  		string
  Variable name:	xexp
  Default value:	r[0]
  Description:		Expression to use as x coordinate
  Long description:     Expression to use as x coordinate


  Short name:		-t
  Long name:  		--markertype
  Value type:  		int
  Variable name:	mt
  Default value:	4
  Description:		Marker type
  Long description:     Marker type

  Short name:		-s
  Long name:  		--markersize
  Value type:  		int
  Variable name:	ms
  Default value:	1
  Description:		Marker size
  Long description:     Marker size

  Short name:		-y
  Long name:  		--y_expression
  Value type:  		string
  Variable name:	yexp
  Default value:	r[1]
  Description:		Expression to use as y coordinate
  Long description:     Expression to use as y coordinate

  Short name:		-X
  Long name:  		--x_label
  Value type:  		string
  Variable name:	xlabel
  Default value:	x
  Description:		text for label of x axis
  Long description:     text for label of x axis

  Short name:		-Y
  Long name:  		--y_label
  Value type:  		string
  Variable name:	ylabel
  Default value:	y
  Description:		text for label of x axis
  Long description:     text for label of x axis



END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)
include NacsParser

pp! options

xexp = expression(scan_expression_string(options.xexp))
yexp = expression(scan_expression_string(options.yexp))

update_commandlog
ENV["GKS_DOUBLE_BUF"]= "true" 
  
if options.wbox[0]== options.wbox[1]
  ws=options.wsize
  setwindow(-ws, ws,-ws, ws)
else
  wv=options.wbox
  setwindow(wv[0],wv[1],wv[2],wv[3])
end

setcharheight(0.05)
setmarkertype(options.mt)
setmarkersize(options.ms)

Nacsio.repeat_on_snapshots{|pp|
  clearws() 
  box
  text(0.5, 0.06, options.xlabel)
  text(0.06, 0.5, options.ylabel)
  text(0.6,0.91,"t="+sprintf("%.3f", pp[0].p.time))
  polymarker(pp.map{|p| eval_expression(xexp,p.y)},
             pp.map{|p| eval_expression(yexp,p.y)})
  updatews()
}  
c=STDERR.gets if ENV["GKS_WSTYPE"]= "x11" 

