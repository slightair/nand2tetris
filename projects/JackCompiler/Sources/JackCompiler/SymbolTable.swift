import Foundation

class SymbolTable {
    enum Kind: String {
        case `static`
        case field
        case arg
        case `var`
    }

    struct Record: CustomStringConvertible {
        let type: String
        let kind: Kind
        let index: Int

        var description: String {
            "\(type)|\(kind)|\(index)"
        }
    }

    private var staticCount = 0
    private var fieldCount = 0
    private var argCount = 0
    private var varCount = 0

    private var classRecords: [String: Record] = [:]
    private var subroutineRecords: [String: Record] = [:]

    func startSubroutine() {
        argCount = 0
        varCount = 0
        subroutineRecords.removeAll()
    }

    func define(name: String, type: String, kind: Kind, isMethod: Bool = false) {
        switch kind {
        case .static:
            classRecords[name] = Record(type: type, kind: kind, index: staticCount)
            staticCount += 1
        case .field:
            classRecords[name] = Record(type: type, kind: kind, index: fieldCount)
            fieldCount += 1
        case .arg:
            let index = isMethod ? argCount + 1 : argCount
            subroutineRecords[name] = Record(type: type, kind: kind, index: index)
            argCount += 1
        case .var:
            subroutineRecords[name] = Record(type: type, kind: kind, index: varCount)
            varCount += 1
        }
    }

    func varCount(kind: Kind) -> Int {
        switch kind {
        case .static, .field:
            return classRecords.values.filter {
                $0.kind == kind
            }.count
        case .arg, .var:
            return subroutineRecords.values.filter {
                $0.kind == kind
            }.count
        }
    }

    func kindOf(name: String) -> Kind? {
        if let record = subroutineRecords[name] {
            return record.kind
        } else if let record = classRecords[name] {
            return record.kind
        }
        return nil
    }

    func typeOf(name: String) -> String? {
        if let record = subroutineRecords[name] {
            return record.type
        } else if let record = classRecords[name] {
            return record.type
        }
        return nil
    }

    func indexOf(name: String) -> Int? {
        if let record = subroutineRecords[name] {
            return record.index
        } else if let record = classRecords[name] {
            return record.index
        }
        return nil
    }
}
