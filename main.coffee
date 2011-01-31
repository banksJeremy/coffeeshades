jQuery ->
    NT = CoffeeScript.require "./nodes" # [N]ode[T]ypes
    
    # I don't find that multipurpose use of $ makes for very readable code.
    make = jQuery
    find = jQuery

    sourceToDOM = (node) ->
        # Converts a source node to a DOM node.
        
        console.debug "Converting source node", node
        
        if node not instanceof NT.Base
            # Given an object that is not a source node, return its string representation in a <span>.

            result = (make "<span class=raw>").text String node
        
        else if node instanceof NT.Expressions
            result = make "<div class=expressions>"
            
            for expression in node.expressions
                result.append (make "<div class=expression>").append sourceToDOM expression
        
        else if node instanceof NT.Assign
            result = make "<span class=assign>"

            result.append sourceToDOM node.variable
            result.append (make "<span class=operator>").text "="
            result.append sourceToDOM node.value

        else if node instanceof NT.Literal
            result = (make "<span class=literal>").text String node.value
        
        else if node instanceof NT.Value
            result = (make "<span class=value>")
            
            result.append (make "<span class=base>").append sourceToDOM node.base
            
            for property in node.properties
                result.append (make "<span class=property>").append sourceToDOM property
       
        else if node instanceof NT.Code
            result = make "<span class=code>"

            if node.params.length
                params = make "<span class=params>"

                for param in node.params
                    params.append (make "<span class=param>").append sourceToDOM param.name # splat? value?

                result.append params

            result.append (make "<span class=operator>").text "->" # what about => ?

            result.append (make "<span class=body>").append sourceToDOM node.body
        
        else if node instanceof NT.Op
            result = make "<span class=op>"

            result.append (make "<span class=operand>").append sourceToDOM node.first
            result.append (make "<span class=operator>").text node.operator
            result.append (make "<span class=operand>").append sourceToDOM node.second
        
        else if node instanceof NT.Call
            result = make "<span class=call>"

            result.append (make "<span class=callee>").append sourceToDOM node.variable
            
            args = make "<span class=args>"

            for arg in node.args
                args.append (make "<span class=arg>").append sourceToDOM arg
            
            result.append args
        
        else if node instanceof NT.Access
            result = sourceToDOM node.name

        else
            result = (make "<span class=unknown>").text "[Unsupported Node #{node.constructor.name}]"

        result
    
    # ---

    display = make "<pre class=source>"

    source = "f = (x, y) -> 2 * x + z\nconsole.log f 9, 10\nz = 2" # use localStorage.source ?= later
    
    ((make "<h1>").text document.title).appendTo find "body"           
    display.append sourceToDOM CoffeeScript.nodes source
    display.appendTo find "body"
    
    sourceOut = (make "<textarea>").text CoffeeScript.nodes(source).compile()
    (find "body").append sourceOut

