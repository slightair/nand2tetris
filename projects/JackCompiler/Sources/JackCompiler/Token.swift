import Foundation

enum Keyword: String, CaseIterable {
    case `class`
    case method
    case function
    case constructor
    case `int`
    case boolean
    case char
    case void
    case `var`
    case `static`
    case field
    case `let`
    case `do`
    case `if`
    case `else`
    case `while`
    case `return`
    case `true`
    case `false`
    case `null`
    case `this`
}

enum Token: Equatable {
    case keyword(Keyword)
    case symbol(String)
    case identifier(String)
    case integerConstant(Int)
    case stringConstant(String)

    var name: String {
        switch self {
        case .keyword:
            return "keyword"
        case .symbol:
            return "symbol"
        case .identifier:
            return "identifier"
        case .integerConstant:
            return "integerConstant"
        case .stringConstant:
            return "stringConstant"
        }
    }

    var value: String {
        switch self {
        case let .keyword(keyword):
            return keyword.rawValue
        case let .symbol(symbol):
            return symbol
        case let .identifier(identifier):
            return identifier
        case let .integerConstant(integer):
            return "\(integer)"
        case let .stringConstant(string):
            return string
        }
    }
}
