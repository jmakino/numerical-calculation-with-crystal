require "clop"
require "./nacsio.cr"
include Math
include Nacsio

optionstr= <<-END
  Description: program to shift the position and velocity of a snapshot
  Long description: program to shift the position and velocity of a snapshot

  Short name:		-x
  Long name:  		--shift-pos
  Value type:  		float vector
  Variable name:	dx
  Default value:	0.0,0.0,0.0
  Description:		Shift value for position
  Long description:     Shift value for position

  Short name:		-v
  Long name:  		--shift-vel
  Value type:  		float vector
  Variable name:	dv
  Default value:	0.0,0.0,0.0
  Description:		Shift value for velocity
  Long description:     Shift value for velocity
END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)

class Body
  YAML.mapping(
    pos: {type: Vector3, key: "r",default: [0.0,0.0,0.0].to_v,},
    vel: {type: Vector3, key: "v",default: [0.0,0.0,0.0].to_v,},
  )  
end

Nacsio.update_commandlog
Nacsio.repeat_on_snapshots(Body.from_yaml(""), true){|pp|
  pp.each{|p|
    p.p.pos += options.dx.to_v
    p.p.vel += options.dv.to_v
    p.print_particle
  }
}
