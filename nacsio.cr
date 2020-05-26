#
# nacsio.cr
#
# Basic YAML-based IO library for
# nacs (new art of computational science)
# Copyright 2020- Jun Makino

require "yaml"
require "./vector3.cr"

struct Vector3    
  def initialize(ctx : YAML::ParseContext, node : YAML::Nodes::Node)
    a=Array(Float64).new(ctx, node)
    @x=a[0]; @y=a[1]; @z=a[2]
  end
end

module Nacsio
  class CommandLog
    YAML.mapping(
      command: {type: String, default: "",},
      log: {type: String, default: "",},
    )
    def self.new
      CommandLog.from_yaml("")
    end            
    def self.new(logstring : String)
      c=CommandLog.new
      c.command = ([PROGRAM_NAME]+ ARGV).join(" ")
      c.log = logstring
      c
    end            
    def to_nacs    
      self.to_yaml.gsub(/---/, "--- !CommandLog")
    end
    def add_command
      @command += "\n"+([PROGRAM_NAME]+ ARGV).join(" ")
      self
    end            

  end  
  
  class Particle
    def to_nacs
      self.to_yaml.gsub(/---/, "--- !Particle")
    end
    def self.new
      Particle.from_yaml("")
    end
    YAML.mapping(
      id: {type: Int64, default: 0i64,},
      time: {type: Float64, key: "t", default: 0.0,},
      mass: {type: Float64, key: "m",default: 0.0,},
      pos: {type: Vector3, key: "r",default: [0.0,0.0,0.0].to_v,},
      vel: {type: Vector3, key: "v",default: [0.0,0.0,0.0].to_v,},
    )  
  end

  def update_commandlog
  s=gets("---")
  s=gets("---") if s == "---"
  a=s.to_s.split("\n")
  a.pop if a[a.size-1]=="---"
  if a[0] != " !CommandLog"
    raise("Input line #{a[0]} not the start of Commandlog")
  else
    a.shift
    ss = (["---\n"] + a).join("\n")
    print CommandLog.from_yaml(ss).add_command.to_nacs
  end
end

  class CP(T)
    property :p, y
    def initialize(p : T, y : YAML::Any)
      @p=p
      @y=y
    end
    def self.read_particle
      s=gets("---")
      retval=CP(T).new(T.from_yaml(""),YAML::Any.new(nil))
      if  s != nil
        a=s.to_s.split("\n")
        a.pop if a[a.size-1]=="---"
        if a.size > 0
          if a[0] != " !Particle"
            raise("Input line #{a[0]} not the start of Particle")
          else
            a.shift
            ystr = (["--- \n"] + a).join("\n")
            retval=CP(T).new(T.from_yaml(ystr), YAML.parse(ystr))
          end
        end
        
      end
      retval
    end
    
    def print_particle
      yy=@y.as_h.to_a
      ycore = YAML.parse(@p.to_yaml).as_h.to_a
      ycore.each{|core|
        yy.reject!{|x| x[0]== core[0]}
      }
      yy = ycore + yy
      newstring = YAML.build{|yaml|
        yaml.mapping{
          yy.each{|x|
            yaml.scalar x[0].as_s
            if x[1].raw.class == Int64
              yaml.scalar x[1].as_i64
            elsif x[1].raw.class == Float64
              yaml.scalar x[1].as_f
            elsif x[1].raw.class == String
              yaml.scalar x[1].as_s
            elsif x[1].raw.class == Array(YAML::Any)
              xx = x[1].as_a
              yaml.sequence { xx.each{|v| yaml.scalar v.as_f}}
            end              
          }
        }
      }
      print newstring.gsub(/---/, "--- !Particle")
    end      
  end
end
