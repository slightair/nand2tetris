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
        lineScanner.charactersToBeSkipped = .whitespaces

        guard let command = lineScanner.scanUpToCharacters(from: .whitespaces) else {
            fatalError()
        }

        if let arithmetic = Command.Arithmetic(rawValue: command) {
            return .arithmetic(arithmetic)
        }

        switch command {
        case "push", "pop":
            guard let arg1 = lineScanner.scanUpToCharacters(from: .whitespaces),
                  let arg2 = lineScanner.scanInt(),
                  let segment = Command.Segment(rawValue: arg1) else {
                fatalError()
            }

            switch command {
            case "push":
                return .push(segment: segment, index: arg2)
            case "pop":
                return .pop(segment: segment, index: arg2)
            default:
                fatalError()
            }
        case "label", "goto", "if-goto":
            guard let label = lineScanner.scanUpToCharacters(from: .whitespaces) else {
                fatalError()
            }

            switch command {
            case "label":
                return .label(label)
            case "goto":
                return .goto(label)
            case "if-goto":
                return .if(label)
            default:
                fatalError()
            }
        case "function":
            guard let functionName = lineScanner.scanUpToCharacters(from: .whitespaces),
                  let numLocals = lineScanner.scanInt() else {
                fatalError()
            }
            return .function(functionName: functionName, numLocals: numLocals)
        case "return":
            return .return
        case "call":
            guard let functionName = lineScanner.scanUpToCharacters(from: .whitespaces),
                  let numArgs = lineScanner.scanInt() else {
                fatalError()
            }
            return .call(functionName: functionName, numArgs: numArgs)
        default:
            fatalError("Not yet implemented: '\(command)'")
        }
    }
}
