require 'sinatra'
infinity = 1.0/0.0
keyvalues = {}

get '/calc/:equation' do
    equation = params[:equation].gsub(" ", "+").gsub("&", " ").gsub(":", "/")
    calc = RPNCalculator.new
    begin
        value = calc.evaluate(equation.to_s)
        if (value == infinity)
            status 400
            "division by zero"
        else
            value.to_s
        end
    rescue
        status 400
        "syntax error"
    end
end

put '/calc2/:id' do
    id = params[:id]
    currentvalue = keyvalues[id]
    if (currentvalue == nil)
        status 404
    else
        equation = params[:equation].gsub(" ", "+").gsub("&", " ").gsub(":", "/").gsub("ACC", currentvalue.to_s)
        calc = RPNCalculator.new
        begin
            newvalue = calc.evaluate(equation.to_s)
            if (newvalue == infinity)
                status 400
                "division by zero"
            else
                keyvalues[id] = newvalue
                newvalue.to_s
            end
        rescue
            status 400
            "syntax error"
        end
    end
end

post '/calc2/' do
    equation = params[:equation].gsub(" ", "+").gsub("&", " ").gsub(":", "/")
    calc = RPNCalculator.new
    rand_id = (0...8).map { (65 + rand(26)).chr }.join
    begin
        value = calc.evaluate(equation)
        if (value == infinity)
            status 400
            "division by zero"
        else
            keyvalues[rand_id] = value
            status 201
            rand_id
        end
    rescue
        status 400
        "syntax error"
    end
end

delete '/calc2/:id' do
    id = params[:id]
    deletedvalue = keyvalues.delete(id)
    if (deletedvalue != nil)
        status 204
    else
        status 404
    end 
end

delete '/calc2/' do
    keyvalues = {}
    status 204
end

get '/calc2/:id' do
    id = params[:id]
    keyvalues[id].to_s
end

get '/calc2/' do
   array = keyvalues.keys
   returnstring = ""
   array.each { |key| returnstring += "#{key}," }
   returnstring
end

class RPNCalculator
  def evaluate rpn
    array = rpn.split(" ").inject([]) do |array, i|    
      if i =~ /\d+/ 
        array << i.to_f
      else
        b = array.pop(2)
        array << b[0].send(i, b[1])
      end
    end
    if (array.length > 1)
        raise "syntax error"
    end
    return array.pop
  end
end


