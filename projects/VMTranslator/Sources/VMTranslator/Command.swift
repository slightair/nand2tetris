import Foundation

enum Command: CustomStringConvertible {
    enum Arithmetic: String, CaseIterable {
        case add
        case sub
        case neg
        case eq
        case gt
        case lt
        case and
        case or
        case not
    }

    enum Segment: String, CaseIterable {
        case argument
        case local
        case `static`
        case constant
        case this
        case that
        case pointer
        case temp
    }

    case arithmetic(Arithmetic)
    case push(segment: Segment, index: Int)
    case pop(segment: Segment, index: Int)
    case label(String)
    case goto(String)
    case `if`(String)
    case function(functionName: String, numLocals: Int)
    case `return`
    case call(functionName: String, numArgs: Int)

    var description: String {
        switch self {
        case let .arithmetic(arithmetic):
            return "\(arithmetic)"
        case let .push(segment: segment, index: index):
            return "push \(segment) \(index)"
        case let .pop(segment: segment, index: index):
            return "pop \(segment) \(index)"
        case let .label(label):
            return "label \(label)"
        case let .goto(label):
            return "goto \(label)"
        case let .if(label):
            return "if \(label)"
        case let .function(functionName: functionName, numLocals: numLocals):
            return "function \(functionName) \(numLocals)"
        case .return:
            return "return"
        case let .call(functionName: functionName, numArgs: numArgs):
            return "call \(functionName) \(numArgs)"
        }
    }
}
