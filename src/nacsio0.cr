#
# nacsio0.cr
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
end
