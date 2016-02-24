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
            }
        }
        return (nil, ops) //stack is empty, kick
    }
    
    //recursively builds a string representation of the op stack
    private func description(ops:[Op]) -> (history: String, remainingOps: [Op]){
        while !ops.isEmpty{
            var opStack = ops;
            let op = opStack.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", opStack)
            case .UnaryOperation(let name, _):
                let recursiveResult = description(opStack)
                let historyString = name + "(" + recursiveResult.history + ")"
                return (historyString, opStack)
            case .BinaryOperation(let name, _):
                let firstResult = description(opStack)
                let secondResult = description(firstResult.remainingOps)
                let historyString = "(" + firstResult.history + name + secondResult.history + ")"
                
                return (historyString, opStack)
            case .Variable(let name):
                return (name, opStack)
            }
            
            
        }
        return ("----", ops)
    }
    
    //removes everything from the opstack
    func clearOpStack(){
        opStack.removeAll()
    }
    
    func getDescription() -> String?{
        return description(opStack).history
    }
    
    //evaluates a result
    func evaluate() -> Double? {
        return evaluate(opStack).result
    }
    
    //push an operand onto the opStack
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        //print("\(opStack)")
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
       // print ("\(opStack)")
        return evaluate()
    }
    
    func setVariable(symbol: String, value: Double){
        variableValues[symbol] = value
    }
    
    //calls evaluate() to perform an operation
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol]{
            opStack.append(operation)
            //print("\(opStack)")
            return evaluate()
        }
        return nil
    }
    
}