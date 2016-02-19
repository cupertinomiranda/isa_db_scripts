class RelocationCalcParser

prechigh
  nonassoc UMINUS
  left '*' '/'
  left '+' '-'
  left BINOP SHIFT
preclow

rule 
  stmt: FUNC '(' stmt_list ')' { return RelocationCalc.new({type: 'func', name: val[0], param: val[2]}) }
      | stmt '-' stmt   { return RelocationCalc.new({type: 'binop', name: val[1],  lhs: val[0], rhs: val[2] }) }
      | stmt '+' stmt   { return RelocationCalc.new({type: 'binop', name: val[1],  lhs: val[0], rhs: val[2] }) }
      | stmt '*' stmt   { return RelocationCalc.new({type: 'binop', name: val[1],  lhs: val[0], rhs: val[2] }) }
      | stmt '/' stmt   { return RelocationCalc.new({type: 'binop', name: val[1],  lhs: val[0], rhs: val[2] }) }
      | stmt '&' stmt   { return RelocationCalc.new({type: 'binop', name: val[1],  lhs: val[0], rhs: val[2] }) }
      | stmt BINOP stmt   { return RelocationCalc.new({type: 'binop', name: val[1],  lhs: val[0], rhs: val[2] }) }
      | '-' stmt =UMINUS  { return RelocationCalc.new({type: 'uniop', name: val[0],               rhs: val[1] }) }
      | '~' stmt =UMINUS  { return RelocationCalc.new({type: 'uniop', name: val[0],               rhs: val[1] }) }
      | UNIOP stmt        { return RelocationCalc.new({type: 'uniop', name: val[0],               rhs: val[1] }) }
      | leaf

  stmt_list: stmt ',' stmt_list   { return [val[0]].push(val[2]) }
           | stmt                 { return [val[0]] }

  leaf: VAR               { return RelocationCalc.new(type: 'var', var: val[0]) }
      | NUMBER            { return RelocationCalc.new(type: 'number', number: val[0]) }
      | HEX_NUMBER        { return RelocationCalc.new(type: 'number', number: val[0]) }
      | '(' stmt ')'      { return val[1] }
  
end

---- inner

def parse(str)
  orig_str = str
  @yydebug = true
  @q = []
  until str.empty?
    append = ""
    case str
      when /\A(&|\||<<|>>)/
        @q.push [:BINOP, $1]
      when /\A([\~])/
        @q.push [:UNIOP, $1]
#      when /\A([\+\-\*\/]|<<|>>|&)/
#        @q.push [:BINOP, $1]
      when /\A(^[a-zA-Z][a-zA-Z0-9]*)\(/
        @q.push [:FUNC, $1]
        append = '('
      when /\A([a-zA-Z_][a-zA-Z0-9_]*)/
        @q.push [:VAR, $1]
      when /\A0x([0-9a-fA-F])+/
        @q.push [:HEX_NUMBER, $&.to_i(16)]
      when /\A\d+/
        @q.push [:NUMBER, $&.to_i]
      when /\A.|\n/o
        s = $&
        @q.push [s, s]
    end
    str = append + $'
  end
  @q.push [false, '$end']
  begin
    do_parse
  rescue  
    puts "Error parsing: --#{orig_str}--"
  end
end

 def next_token
  @q.shift
 end

---- footer

class RelocationCalc
  def initialize(params)
    @object = params
  end


  def self.parse(string)
    puts "Parsing: #{string}"
    RelocationCalcParser.new.parse(string)
  end

#  def debug()
#    case @object[:type]
#      when /binop/
#        return "(#{@object[:lhs].debug})#{@object[:name]}(#{@object[:rhs].debug})"
#      when /uniop/
#        return "(#{@object[:name]}(#{@object[:rhs].debug})"
#      when /var/
#        return "(#{@object[:var]})"
#      when /number/
#        return "(#{@object[:number]})"
#      else
#        raise "Object type is invalid"
#    end
#  end

  def to_c(r={})
    case @object[:type]
      when /binop/
        return "( #{@object[:lhs].to_c(r)} #{@object[:name]} #{@object[:rhs].to_c(r)} )"
      when /uniop/
        return "( #{@object[:name]}#{@object[:rhs].to_c(r)} )"
      when /func/
        return "( #{@object[:name]} ( #{@object[:param].map {|p| p.to_c(r) }.join(",") } ) )"
      when /var/
        var_name = @object[:var].to_sym
        #puts "VAR_NAME= #{var_name}"
        return r[var_name] if r[var_name] != nil
        return @object[:var]
      when /number/
        return "#{@object[:number]}"
      else
        raise "Object type is invalid #{self}"
    end
    
  end
end
