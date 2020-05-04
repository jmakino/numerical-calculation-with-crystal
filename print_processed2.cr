
sum=gets("").to_s.chomp.split("\n").map{|s| s.split.map{|x| x.to_i}}
  .map{|x| localsum=x[3..5].sum
  print localsum,"\n"
  localsum}.sum
print "Total=", sum, "\n"
