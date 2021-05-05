import Foundation

class JackTokenizer {
    static let singleLineCommentPrefix = "//"
    static let multiLineCommentPrefix = "/*"
    static let multiLineCommentSuffix = "*/"
    static let apiCommentPrefix = "/**"
    static let stringConstantDelimiter = "\""
    static let symbols = [
        "{", "}", "(", ")", "[", "]", ".", ",", ";", "+", "-", "*", "/", "&", "|", "<", ">", "=", "~",
    ]
    static let identifierCharcterSet: CharacterSet = {
        var characterSet = CharacterSet.alphanumerics
        characterSet.formUnion(CharacterSet(charactersIn: "_"))
        return characterSet
    }()

    private let tokens: [Token]
    private var cursor = 0

    var hasMoreTokens: Bool {
        cursor < tokens.count
    }

    var currentToken: Token {
        tokens[cursor]
    }

    var nextToken: Token {
        tokens[cursor + 1]
    }

    init(fileURL: URL) throws {
        let sourceCode = try String(contentsOfFile: fileURL.path)
        tokens = Self.parse(string: sourceCode)
    }

    func advance() {
        cursor += 1
    }

    private static func parse(string: String) -> [Token] {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = .whitespacesAndNewlines

        func scanComment() -> String? {
            var comment: String?
            if scanner.scanString(Self.singleLineCommentPrefix) != nil {
                comment = scanner.scanUpToCharacters(from: .newlines)
            } else if scanner.scanString(Self.apiCommentPrefix) != nil || scanner.scanString(Self.multiLineCommentPrefix) != nil {
                comment = scanner.scanUpToString(Self.multiLineCommentSuffix)
                _ = scanner.scanString(Self.multiLineCommentSuffix)
            }
            return comment
        }

        func scanSymbol() -> String? {
            for symbol in symbols {
                if let next = scanner.scanString(symbol) {
                    return next
                }
            }
            return nil
        }

        func scanKeyword() -> Keyword? {
            for keyword in Keyword.allCases {
                if let raw = scanner.scanString(keyword.rawValue), let next = Keyword(rawValue: raw) {
                    return next
                }
            }
            return nil
        }

        func scanIntegerConstant() -> Int? {
            scanner.scanInt()
        }

        func scanStringConstant() -> String? {
            var string: String?
            if scanner.scanString(Self.stringConstantDelimiter) != nil {
                string = scanner.scanUpToString(Self.stringConstantDelimiter)
                _ = scanner.scanString(Self.stringConstantDelimiter)
            }
            return string
        }

        func scanIdentifier() -> String? {
            scanner.scanCharacters(from: Self.identifierCharcterSet)
        }

        var tokens: [Token] = []
        while !scanner.isAtEnd {
            if scanComment() != nil {
                // nothing to do
            } else if let symbol = scanSymbol() {
                tokens.append(.symbol(symbol))
            } else if let keyword = scanKeyword() {
                tokens.append(.keyword(keyword))
            } else if let integer = scanIntegerConstant() {
                tokens.append(.integerConstant(integer))
            } else if let string = scanStringConstant() {
                tokens.append(.stringConstant(string))
            } else if let identifier = scanIdentifier() {
                tokens.append(.identifier(identifier))
            } else {
                let unexpectedString = scanner.scanUpToCharacters(from: .whitespacesAndNewlines) ?? "<nil>"
                fatalError("Unexpected input: '\(unexpectedString)'")
            }
        }
        return tokens
    }
}
