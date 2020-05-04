sum=gets("").to_s.chomp.split("\n").map{|s| s.split.map{|x| x.to_i}}
  .map{|x| x[3..5].sum}.sum
print "Total=", sum, "\n"
