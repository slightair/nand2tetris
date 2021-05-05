import ArgumentParser

enum Mode: String, EnumerableFlag {
    case tokenizer
    case parser
    case compiler
}

struct JackCompiler: ParsableCommand {
    @Flag var mode: Mode = .compiler
    @Argument var fileOrDirectory: String

    mutating func run() throws {
        switch mode {
        case .tokenizer:
            try JackAnalyzer.tokenize(fileOrDirectory: fileOrDirectory)
        case .parser:
            try JackAnalyzer.parse(fileOrDirectory: fileOrDirectory)
        default:
            fatalError("Not yet implemented")
        }
    }
}

JackCompiler.main()
