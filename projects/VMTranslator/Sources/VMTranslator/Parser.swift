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
        default:
            fatalError("Not yet implemented: '\(command)'")
        }
    }
}
