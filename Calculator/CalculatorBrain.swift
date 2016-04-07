//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by John Truskowski on 2/2/16.
//  Copyright © 2016 John Truskowski. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues: Dictionary<String,Double> = Dictionary<String,Double>()
    
    private enum Op { //CustomDebug protocol
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        case Constant(String, Double)
    }
    
    init(){
        //all the known operations reside here
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["tan"] = Op.UnaryOperation("tan", tan)
        knownOps["π"] = Op.Constant("π", M_PI)
    }
    
    //evaluates a result recursively using the operators/operands in the stack
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){ //tuple
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    let operandEvaluation2 = evaluate(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result{
                        return (operation(operand, operand2), operandEvaluation2.remainingOps)
                    }
                }
                
            case .Variable(let variable):
                if let varValue = variableValues[variable]{
                    return (varValue, remainingOps) //returns the value of a variable, or nil if it doesn't have a value
                }
                
            case .Constant(_, let value):
                return(value, remainingOps)
            }
        }
        return (nil, ops) //stack is empty, kick
    }
    
    //called by the view controller, calls the helper function and returns the string
    var description : String {
        get {
            var alreadyLooped = false
            var builderString = ""
            var firstDescrip = description(opStack)
            
            repeat{
                if(alreadyLooped == true){
                    firstDescrip = description(firstDescrip.remainingOps)
                    
                    let updatedHistory = removeOutsideParens(firstDescrip.history)
                    let secondString = removeOutsideParens(builderString)
                    
                    let tempString = updatedHistory + ", " + secondString
                    builderString = tempString
                }else{
                    builderString += firstDescrip.history
                }
                
                alreadyLooped = true
                
            }while firstDescrip.remainingOps.count > 0
            
            let finalString = removeOutsideParens(builderString)
            
            return finalString
        }
    }
    
    //returns just the last set of operations on the brain's stack (for the graph's description)
    var mostRecentDescription : String {
        get {
            let temp = description(opStack).history
            let finalString = removeOutsideParens(temp)
            return finalString
        }
    }
    
    //recursively builds a string representation of the op stack
    private func description(ops:[Op]) -> (history: String, remainingOps: [Op]){
        while !ops.isEmpty{
            var remainOps = ops;
            let op = remainOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainOps)
            case .UnaryOperation(let name, _):
                let recursiveResult = description(remainOps)
               
                let historyString = name + "(" + recursiveResult.history + ")"
                return (historyString, recursiveResult.remainingOps)
                
            case .BinaryOperation(let name, _):
                let firstResult = description(remainOps)
                let secondResult = description(firstResult.remainingOps)
                
                print(firstResult.remainingOps.count, " ", remainOps.count)
                if(secondResult.remainingOps.count != firstResult.remainingOps.count){
                    return (("(" + secondResult.history + name + firstResult.history + ")"), secondResult.remainingOps)
                }else{
                    return ((secondResult.history + name + firstResult.history), secondResult.remainingOps)
                }
                
            case .Variable(let name):
                return (name, remainOps)
                
            case .Constant(let name, _):
                return (name, remainOps)
            }
            
            
        }
        return (" ", ops)
    }
    
    //removes the outermost parentheses from the expression (if they exist)
    func removeOutsideParens(descripString: String) -> String {
        
        if(descripString == "" || descripString.characters.count<3){
            return descripString
        }
        
        
        let firstChar = descripString.substringWithRange(Range<String.Index>(start: descripString.startIndex, end: descripString.startIndex.advancedBy(1)))
        let lastChar = descripString.substringWithRange(Range<String.Index>(start: descripString.endIndex.advancedBy(-1), end: descripString.endIndex))
        
        var returnString = ""
    
        if(firstChar == "(" && lastChar == ")"){
            returnString = descripString.substringWithRange(Range<String.Index>(start: descripString.startIndex.advancedBy(1), end: descripString.endIndex.advancedBy(-1)))
        }else{
            returnString = descripString
        }
        
        return returnString
    }
    
    
    //removes everything from the opstack
    func clearOpStack(){
        opStack.removeAll()
    }
    
    //evaluates a result
    func evaluate() -> Double? {
        return evaluate(opStack).result
    }
    
    //push an operand onto the opStack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        
        if let constant = knownOps[symbol]{
            opStack.append(constant)
        }else{
            opStack.append(Op.Variable(symbol))
        }
        return evaluate()
    }
    
    func setVariable(symbol: String, value: Double){
        variableValues[symbol] = value
    }
    
    //calls evaluate() to perform an operation
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol]{
            opStack.append(operation)
            return evaluate()
        }
        return nil
    }
    
}