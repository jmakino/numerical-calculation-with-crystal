module NacsParser
include Math
  # Grammar  
  # expression -> [sign] term { add_op term}
  # sign -> +|-
  # add_op -> +|-
  # term -> factor {mul_op factor}
  # mul_op -> *|/
  # factor -> variable|element|constant|function| (expression) 
  # function -> function_name(parameters)
  # parameters -> expression {,expression}
  
  extend self
  enum Ttype
    Add
    Mul
    Variable
    Element
    Constant
    Open_Paren
    Close_Paren
    Comma
    Fapply
  end  

  class Token
    property s, t
    def initialize(s : String,t : Ttype)
      @s=s
      @t=t
    end
    def ppp(currentindent : Int64 = 0,  indent : Int64 = 4)
      print " "*currentindent, @s,"(#{@t.to_s})\n"
    end
  end

  def scan_expression_string(s)
    original_s=s
    s= s.delete(" ")
    tokens=Array(Token).new
    while s.size>0
      len = 1
      if s[0] == '('
        tokens.push(Token.new("(", Ttype::Open_Paren))
      elsif s[0] == ')'
        tokens.push(Token.new(")", Ttype::Close_Paren))
      elsif  /^([1-9][0-9]*\.[0-9]*e[+-]?[0-9]+)/ =~ s
        tokens.push(Token.new($1, Ttype::Constant))
        len = $1.size
      elsif  /^([1-9][0-9]*\.[0-9]*)/  =~ s
        tokens.push(Token.new($1, Ttype::Constant))
        len = $1.size
      elsif /^([a-z_][a-z_0-9]*\[[0-9]+\])/ =~ s
        tokens.push(Token.new($1, Ttype::Element))
        len = $1.size
      elsif /^([a-z_][a-z_0-9]*)/ =~ s
        tokens.push(Token.new($1, Ttype::Variable))
        len = $1.size
      elsif /^([\+-])/ =~ s
        tokens.push(Token.new($1, Ttype::Add))
      elsif /^([\*\/])/ =~ s
        tokens.push(Token.new($1, Ttype::Mul))
      elsif s[0] == ','
        tokens.push(Token.new(",", Ttype::Comma))
      else
        STDERR.print "Error unrecognizable expression\n"
        pp! original_s
        STDERR.print "Error at", s, "\n"      
        exit
      end
      s = s[len..(s.size-1)]
    end
    tokens
  end

  class Node
    property :operator, :lhs, :rhs
    def initialize(operator : Token, lhs : (Node|Token|Nil) ,
                   rhs : (Node|Token|Nil) )
      @operator=operator
      @lhs = lhs
      @rhs = rhs
    end
    def ppp(currentindent : Int64 = 0,  indent : Int64 = 4)
      @lhs.ppp(currentindent+indent, indent) if @lhs
      print " "*currentindent, @operator.s,"\n"
      @rhs.ppp(currentindent+indent, indent) if @rhs
    end
  end                                                                   
  
  def expression(token)
    if token[0].t== Ttype::Add
      n=Node.new(token[0], nil, expression(token))
      token.shift
    else  
      n =  term(token)
      while token.size >0 && token[0].t== Ttype::Add
        op= token.shift
        n=Node.new(op, n, term(token))
      end
    end
    n
  end

  def term(token)
    n = factor(token)
    while  token.size > 0 &&  token[0].t == Ttype::Mul
      op= token.shift
      n=Node.new(op, n, factor(token))
    end
    n
  end

  def factor(token)
    if token[0].t== Ttype::Variable||token[0].t== Ttype::Element||
       token[0].t== Ttype::Constant
      n=token.shift
      if token.size >1 &&token[0].t == Ttype::Open_Paren
        token.shift
        n=Node.new(Token.new("Apply", Ttype::Fapply), n, parameters(token))
        if token[0].t == Ttype::Close_Paren
          token.shift
        else
          print "error"
          pp! n
          pp! token
        end
      end
    elsif token[0].t== Ttype::Open_Paren
      token.shift
      n=expression(token)
      if token[0].t == Ttype::Close_Paren
        token.shift
      else
        print "error"
        pp! n
        pp! token
      end
    end
    n
  end   

  def parameters(token)
    n = expression(token)
    while  token.size > 0 &&  token[0].t == Ttype::Comma
      op= token.shift
      n=Node.new(op, n, expression(token))
    end
    n
  end

  def eval_expression(e : (Node|Token|Nil), t : YAML::Any)
    val=0.0
    if e.is_a?(Token)
      if e.t == Ttype::Constant
        val= e.s.to_f
      elsif e.t == Ttype::Variable
        val = t[e.s].as_f
      elsif  e.t == Ttype::Element
        /^([a-z_][a-z_0-9]*)\[([0-9]+)\]/ =~ e.s
        vname=$1
        index = ($2).to_i
        val = t[vname][index].as_f
      end
    elsif e.is_a?(Node)
      lhval=0.0
      rhval=0.0
      if e.operator.s== "Apply"
        val = eval_function(e.lhs, e.rhs, t)
      else
        lhval = eval_expression(e.lhs, t) unless e.lhs.is_a?(Nil)
        rhval = eval_expression(e.rhs, t) unless e.rhs.is_a?(Nil)
        if e.operator.s== "+"
          val = lhval+rhval
        elsif e.operator.s== "-"
          val = lhval-rhval
        elsif e.operator.s== "*"
          val = lhval*rhval
        elsif e.operator.s== "/"
          val = lhval/rhval
        end
      end
    end      
    val
  end
  
  def eval_function(f : (Node|Token|Nil),
                args : (Node|Token|Nil),
                t : YAML::Any)
    val=0.0
    if f.is_a?(Token)
      fname= f.s
      vals=Array(Float64).new
      while args.is_a?(Node) && args.operator.s == "Apply"
        vals.unshift eval_expression(args.rhs, t)
        args = args.lhs
      end
      vals.unshift eval_expression(args, t)
      if fname == "sqrt"
        val = sqrt(vals[0])
      elsif fname == "exp"
        val = exp(vals[0])
      elsif fname == "log"
        val = log(vals[0])
      elsif fname == "exp"
        val = exp(vals[0])
      elsif fname == "pow"
        val = vals[0]**vals[1]
      end
    end
    val
  end
end

struct  Nil
  def ppp(currentindent : Int64 = 0,  indent : Int64 = 4)
  end
end
