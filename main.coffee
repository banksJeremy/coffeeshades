#!/usr/bin/env coffee@1.0.0

# -- Globals --

find = jQuery
make = jQuery

nodeTypes = CoffeeScript.require "./nodes"

localStorage ?= {}
debug = (args...) -> console?.debug? args...

# -- Config --

updateDelay = 250
defaultSource = """sub = (a, b) -> a - b
print sub 1 + 2, 3 + (4 * 5)"""

# -- Main --

renderNode = (node) ->
    debug "Rendering node", node
    
    if node instanceof nodeTypes.Expressions
        result = make "<span class=expressions>"
        
        first = true
        
        for child in node.expressions
            result.append renderNode child
            
            if first
                first = false
            else
                result.append make "<br>"
                
    
    else if node instanceof nodeTypes.Assign
        result = make "<span class=assign>"
        
        result.append renderNode node.variable
        result.append (make "<span class=operator>").text " = "
        result.append renderNode node.value
    
    else if node instanceof nodeTypes.Value
        result = renderNode node.base
    
    else if node instanceof nodeTypes.Literal
        result = (make "<span class=literal>").text String node.value
    
    else if node instanceof nodeTypes.Op
        result = make "<span class=op>"
        
        result.append renderNode node.first
        result.append (make "<span class=operator>").text " #{node.operator} "
        result.append renderNode node.second
    
    else if node instanceof nodeTypes.Parens
        result = renderNode node.body
    
    else if node instanceof nodeTypes.Call
        result = make "<span class=call>"
        
        result.append renderNode node.variable
        
        if node.args.length
            args = make "<span class=args>"
            
            for argNode in node.args
                args.append renderNode argNode
            
            result.append args
    
    else if node instanceof nodeTypes.Code
        result = make "<span class=code>"
        
        if node.params.length
            args = make "<span class=args>"
            
            for argNode in node.params
                args.append renderNode argNode
            
            result.append args
        
        result.append renderNode node.body
    
    else if node instanceof nodeTypes.Param
        result = renderNode node.name
    
    else
        result = (make "<span class=unknown>").text "[???]"
    
    result

main = ->
    debug "Entering main."
    
    body = find "body"
    
    interface = make "<div>"
    
    input = make "<textarea class=input>"
    display = make "<div class=display>"
    output = make "<textarea class=output disabled>"
    
    update = ->
        debug "Update triggered."
        
        source = input.val()
        
        display.empty()
        
        try
            root = CoffeeScript.nodes source
        catch error
            output.val String error
            interface.addClass "error"
            return
        
        localStorage.source = source
        
        display.append renderNode root
        
        interface.removeClass "error"
        output.val root.compile()
    
    updateTimeout = null
    
    input.keyup ->
        if updateTimeout?
            clearTimeout updateTimeout
        
        updateTimeout = setTimeout update, updateDelay
    
    input.val if localStorage.source?.length then localStorage.source else defaultSource
    update()
    
    interface.append(input)
             .append(display)
             .append(output)
    
    body.append interface

jQuery(document).ready main
