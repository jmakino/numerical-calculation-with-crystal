require "./narray2.cr"

x =Narray(Float64).new(10)
x[1]=2.0
pp! x
xy =Narray(Float64).new(4,4)
16.times{|i| xy[i]=i.to_f64}
xy[2,3]=-1.0
4.times{|i| 
  4.times{|j|print " ",xy[i,j]}
  print "\n"
}
pp! x[11]
