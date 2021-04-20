import Foundation

class Parser {
    private let commands: [Command]
    private var cursor = 0

    var hasMoreCommands: Bool {
        cursor < commands.count
    }

    var currentCommand: Command {
        commands[cursor]
    }

    init(contentsOfFile file: String) throws {
        let fileData = try String(contentsOfFile: file)
        commands = fileData.components(separatedBy: .newlines)
                .map { line in
                    line.components(separatedBy: "//").first!
                            .trimmingCharacters(in: .whitespaces)
                }
                .filter { line in
                    !line.isEmpty
                }
                .map(Self.parse)
    }

    func advance() {
        cursor += 1
    }

    func reset() {
        cursor = 0
    }

    private static func parse(line: String) -> Command {
        let lineScanner = Scanner(string: line)
        lineScanner.charactersToBeSkipped = CharacterSet(charactersIn: " @()=;")

        if line.hasPrefix("@") {
            if let address = lineScanner.scanInt() {
                return .address(.raw(address))
            } else if let symbol = lineScanner.scanUpToCharacters(from: .newlines) {
                return .address(.symbol(symbol))
            }
            fatalError()
        } else if line.hasPrefix("(") {
            if let symbol = lineScanner.scanUpToString(")") {
                return .label(symbol)
            }
            fatalError()
        } else {
            let dest: String?
            let comp: String
            let jump: String?

            let destAndComp = lineScanner.scanUpToString(";")!
            if lineScanner.isAtEnd {
                jump = nil
            } else {
                jump = lineScanner.scanUpToCharacters(from: .newlines)
            }

            let destAndCompScanner = Scanner(string: destAndComp)
            destAndCompScanner.charactersToBeSkipped = CharacterSet(charactersIn: "=")
            let destOrComp = destAndCompScanner.scanUpToString("=")!
            if destAndCompScanner.isAtEnd {
                dest = nil
                comp = destOrComp
            } else {
                dest = destOrComp
                comp = destAndCompScanner.scanUpToCharacters(from: .newlines)!
            }

            return .calculate(dest: dest, comp: comp, jump: jump)
        }
    }
}
