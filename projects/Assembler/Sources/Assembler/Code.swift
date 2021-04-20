import Foundation

extension String {
    static func binaryRepresentation(value: Int, length: Int) -> String {
        let binaryString = String(value, radix: 2)
        let paddingCount = length - binaryString.count
        if paddingCount > 0 {
            return String(repeating: "0", count: paddingCount) + binaryString
        } else {
            return binaryString
        }
    }
}

struct Code {
    static let destTable: [String?: Int] = [
        nil: 0b000,
        "M": 0b001,
        "D": 0b010,
        "MD": 0b011,
        "A": 0b100,
        "AM": 0b101,
        "AD": 0b110,
        "AMD": 0b111,
    ]

    static let compTable: [String: Int] = [
        "0": 0b0101010,
        "1": 0b0111111,
        "-1": 0b0111010,
        "D": 0b0001100,
        "A": 0b0110000,
        "!D": 0b0001101,
        "!A": 0b0110001,
        "-D": 0b0001111,
        "-A": 0b0110011,
        "D+1": 0b0011111,
        "A+1": 0b0110111,
        "D-1": 0b0001110,
        "A-1": 0b0110010,
        "D+A": 0b0000010,
        "D-A": 0b0010011,
        "A-D": 0b0000111,
        "D&A": 0b0000000,
        "D|A": 0b0010101,
        "M": 0b1110000,
        "!M": 0b1110001,
        "-M": 0b1110011,
        "M+1": 0b1110111,
        "M-1": 0b1110010,
        "D+M": 0b1000010,
        "D-M": 0b1010011,
        "M-D": 0b1000111,
        "D&M": 0b1000000,
        "D|M": 0b1010101,
    ]

    static let jumpTable: [String?: Int] = [
        nil: 0b000,
        "JGT": 0b001,
        "JEQ": 0b010,
        "JGE": 0b011,
        "JLT": 0b100,
        "JNE": 0b101,
        "JLE": 0b110,
        "JMP": 0b111,
    ]

    static func binaryString(dest: String?) -> String {
        guard let binary = destTable[dest] else {
            fatalError()
        }
        return String.binaryRepresentation(value: binary, length: 3)
    }

    static func binaryString(comp: String) -> String {
        guard let binary = compTable[comp] else {
            fatalError()
        }
        return String.binaryRepresentation(value: binary, length: 7)
    }

    static func binaryString(jump: String?) -> String {
        guard let binary = jumpTable[jump] else {
            fatalError()
        }
        return String.binaryRepresentation(value: binary, length: 3)
    }

    static func binaryString(command: Command) -> String {
        switch command {
        case let .address(address):
            switch address {
            case .symbol:
                fatalError()
            case let .raw(raw):
                return "0" + String.binaryRepresentation(value: raw, length: 15)
            }
        case .label:
            fatalError()
        case let .calculate(dest: dest, comp: comp, jump: jump):
            return "111\(binaryString(comp: comp))\(binaryString(dest: dest))\(binaryString(jump: jump))"
        }
    }
}
