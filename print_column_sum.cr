a=gets("").to_s.chomp.split("\n").map{|s| s.split.map{|x| x.to_i}}
sum=Array.new(a[0].size,0)
a.each{|x|  x.each_index{|i| sum[i]+=x[i]}}
p sum
