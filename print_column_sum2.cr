a=gets("").to_s.chomp.split("\n").map{|s| s.split.map{|x| x.to_i}}
p a.reduce{|sum,x|  sum=sum.map_with_index{|val,i| val+x[i]}}
