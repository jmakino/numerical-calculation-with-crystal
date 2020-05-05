#
# rklib.cr
# Explicit Runge Kutta functions in Crystal
#
module RungeKuttaIntegrators
  extend self
  TABLE_CLASSIC4_TEXT =<<-END
  0
  1/2 1/2
  1/2  0     1/2
  1    0      0       1
  C    1/6  2/6      2/6 1/6
  END

  TABLE_DOPRI5_TEXT =<<-END
  0
  1/5 1/5
  3/10 3/40 9/40
  4/5  44/45 -56/15 32/9
  8/9 19372/6561 -25360/2187 64448/6561 -212/729
  1   9017/3168 -355/33 46732/5247 49/176 -5103/18656
  1   35/384    0       500/1113  125/192 -2187/6784 11/84
  C   35/384    0       500/1113  125/192 -2187/6784 11/84 0
  CL 5179/57600 0  7571/16695 393/640  -92097/339200 187/2100 1/40
  END

  TABLE_RKF78_TEXT =<<-END
  0
  2/27 2/27
  1/9 1/36 3/36
  1/6 1/24 0  3/24
  5/12 20/48 0 -75/48 75/48
  1/2 1/20 0 0 5/20 4/20
  5/6 -25/108 0 0 125/108 -260/108 250/108
  1/6 31/300 0 0 0 61/225 -2/9 13/900 
  2/3 2 0 0 -53/6 704/45 -107/9 67/90 3
  1/3 -91/108 0 0 23/108  -976/135 311/54 -19/60 17/6 -1/12
  1 2383/4100 0 0 -341/164 4496/1025 -301/82 2133/4100 45/82 45/164 18/41
  0 3/205 0 0 0 0 -6/41 -3/205 -3/41 3/41 6/41 0
  1 -1777/4100 0 0 -341/164 4496/1025 -289/82 2193/4100 51/82 33/164 12/41 0 1
  C  41/840 0 0 0 0 34/105 9/35 9/35 9/280  9/280 41/840  0 0
  CL 0 0 0 0 0 34/105 9/35 9/35 9/280 9/289 0 41/840  41/840 
  END

  def rat2f(s)
    a = s.split("/")
    if a.size > 1
      a[0].to_f / a[1].to_f
    else
      a[0].to_f
    end
  end
  
  def decode_table(s)
    lines= s.split("\n")
    stages = lines.size-1
    stages -= 1 if lines[lines.size-1].split[0] == "CL"
    a=[rat2f(lines[0])]
    b=[Array(Float64).new]
    lines.shift
    ablines = lines[0..(stages-2)]
    ablines.each{|s|
      coefs = s.split.map{|x| rat2f(x)}
      a.push coefs[0]
      coefs.shift
      b.push coefs
    }

    clines = lines[(stages-1)..(lines.size-1)]
    c = clines[0].split
    c.shift
    c = c.map{|x| rat2f(x)}
    cl = Array(Float64).new
    if clines.size > 1
      cl = clines[1].split
      cl.shift
      cl = cl.map{|x| rat2f(x)}
    end
    a.shift
    b.shift
    {a,b,c,cl}
  end
  TABLE_CLASSIC4 = decode_table(TABLE_CLASSIC4_TEXT)
  TABLE_DOPRI5 = decode_table(TABLE_DOPRI5_TEXT)
  TABLE_RKF78 = decode_table(TABLE_RKF78_TEXT)

  def general_explicit_runge_kutta(x,t,h,f,table)
    a=table[0]
    b=table[1]
    c=table[2]
    k = [f.call(x,t)]
    a.each_with_index{|ai, i|
      xi = x
      b[i].size.times{|j| xi += k[j]*b[i][j]*h}
      k.push f.call(xi, t+h*ai)
    }
    xnew = x
     c.size.times{|j| xnew += k[j]*c[j]*h}
    {xnew, t+h}
  end
  def classic_rk4(x,t,h,f)
    general_explicit_runge_kutta(x,t,h,f,TABLE_CLASSIC4)
  end
  def dopri5(x,t,h,f)
    general_explicit_runge_kutta(x,t,h,f,TABLE_DOPRI5)
  end
  def rkf78(x,t,h,f)
    general_explicit_runge_kutta(x,t,h,f,TABLE_RKF78)
  end
end

