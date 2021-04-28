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
    case label
    case goto
    case `if`
    case function
    case `return`
    case call

    var description: String {
        switch self {
        case let .arithmetic(arithmetic):
            return "\(arithmetic)"
        case let .push(segment: segment, index: index):
            return "push \(segment) \(index)"
        case let .pop(segment: segment, index: index):
            return "pop \(segment) \(index)"
        case .label:
            return "label"
        case .goto:
            return "goto"
        case .if:
            return "if"
        case .function:
            return "function"
        case .return:
            return "return"
        case .call:
            return "call"
        }
    }
}
