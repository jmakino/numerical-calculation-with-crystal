require "clop"
require "./nacsio.cr"
include Math
include Nacsio

optionstr= <<-END
  Description: program to add multiple snapshots to create one file
  Long description: program to add multiple snapshots to create one file

  Short name:		-i
  Long name:  		--input-files
  Value type:  		string
  Variable name:	fnames
  Default value:	none
  Description:		comma-separated list of input files
  Long description:     comma-separated list of input files

  Short name:		-r
  Long name:  		--reset-id
  Value type:  		bool
  Variable name:	reset_id
  Description:		if true, reset id of particles
  Long description:     if true, reset id of particles

END

clop_init(__LINE__, __FILE__, __DIR__, "optionstr")
options=CLOP.new(optionstr,ARGV)
def write(body, ybody)
  body.size.times{|i|
    CP.new(body[i], ybody[i]).print_particle
  }
end
def read(body,ybody, f)
  while (sp= CP(typeof(body[0])).read_particle(f)).y != nil
    body.push sp.p
    ybody.push sp.y
  end
end

class Body
  YAML.mapping(
    id: {type: Int64, default: 0i64,},
  )  
end

body = Array(Body).new
ybody= Array(YAML::Any).new

c = CommandLog.new
options.fnames.split(",").each{|fn|
  File.open(fn,"r"){|f|
    c1 = read_commandlog(f)
    c.command +=  "\n"+c1.command
    c.log += "\n"+c1.log
    read(body,ybody,f)
  }
}
print c.add_command.to_nacs
body.each_with_index{|b,i| b.id=i.to_i64} if options.reset_id
write(body,ybody)
