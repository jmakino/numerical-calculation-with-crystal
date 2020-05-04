s=gets("")
a=s.to_s.split
aint = a.map{|x| x.to_i}
sum = aint.sum
print "sum=#{sum}\n"
