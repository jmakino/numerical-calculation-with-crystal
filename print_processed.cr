sum=0
gets("").to_s.chomp.split("\n").map{|s| s.split.map{|x| x.to_i}}
  .each{|x| localsum=x[3..5].sum
  print localsum,"\n"
  sum+= localsum}
print "Total=", sum, "\n"
