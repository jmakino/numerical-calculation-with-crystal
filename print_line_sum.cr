a=gets("").to_s.chomp.split("\n").map{|s| s.split.map{|x| x.to_i}}
a.each{|x| print x.sum,"\n"}  
