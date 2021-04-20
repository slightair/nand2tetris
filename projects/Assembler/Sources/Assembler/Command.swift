import Foundation

enum Command {
    enum Address {
        case symbol(String)
        case raw(Int)
    }

    case address(Address)
    case calculate(dest: String?, comp: String, jump: String?)
    case label(String)

    var symbol: Address {
        switch self {
        case let .address(address):
            return address
        case .calculate:
            fatalError()
        case let .label(label):
            return .symbol(label)
        }
    }

    var dest: String? {
        switch self {
        case .address:
            fatalError()
        case let .calculate(dest: dest, comp: _, jump: _):
            return dest
        case .label:
            fatalError()
        }
    }

    var comp: String {
        switch self {
        case .address:
            fatalError()
        case let .calculate(dest: _, comp: comp, jump: _):
            return comp
        case .label:
            fatalError()
        }
    }

    var jump: String? {
        switch self {
        case .address:
            fatalError()
        case let .calculate(dest: _, comp: _, jump: jump):
            return jump
        case .label:
            fatalError()
        }
    }
}
