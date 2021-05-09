import ArgumentParser
import Foundation

enum Mode: String, EnumerableFlag {
    case tokenizer
    case parser
    case compiler
}

struct JackCompiler: ParsableCommand {
    enum CompilerError: Error {
        case fileNotFound
    }

    @Flag var mode: Mode = .compiler
    @Argument var fileOrDirectory: String

    mutating func run() throws {
        switch mode {
        case .tokenizer:
            try tokenize(fileOrDirectory: fileOrDirectory)
        case .parser:
            try parse(fileOrDirectory: fileOrDirectory)
        case .compiler:
            try compile(fileOrDirectory: fileOrDirectory)
        }
    }

    private func tokenize(fileOrDirectory: String) throws {
        let fileURLs = try targetFileURLs(fileOrDirectory: fileOrDirectory)
        try fileURLs.forEach { fileURL in
            let xmlWriter = try XMLWriter(fileURL: outFileURL(for: fileURL, suffix: "T.xml"))
            let tokenizer = try JackTokenizer(fileURL: fileURL)

            xmlWriter.writeOpen(name: "tokens")
            while tokenizer.hasMoreTokens {
                let token = tokenizer.currentToken
                xmlWriter.writeElement(name: token.name, innerText: token.value)
                tokenizer.advance()
            }
            xmlWriter.writeClose(name: "tokens")
        }
    }

    private func parse(fileOrDirectory: String) throws {
        let fileURLs = try targetFileURLs(fileOrDirectory: fileOrDirectory)
        try fileURLs.forEach { fileURL in
            let engine = try CompilationEngine(inFileURL: fileURL, outXMLFileURL: outFileURL(for: fileURL, suffix: ".xml"))
            engine.compileClass()
        }
    }

    private func compile(fileOrDirectory: String) throws {
        let fileURLs = try targetFileURLs(fileOrDirectory: fileOrDirectory)
        try fileURLs.forEach { fileURL in
            let engine = try CompilationEngine(inFileURL: fileURL, outVMFileURL: outFileURL(for: fileURL, suffix: ".vm"))
            engine.compileClass()
        }
    }

    private func targetFileURLs(fileOrDirectory: String) throws -> [URL] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: fileOrDirectory, isDirectory: &isDirectory) else {
            throw CompilerError.fileNotFound
        }

        let fileURLs: [URL]
        if isDirectory.boolValue {
            let directoryURL = URL(fileURLWithPath: fileOrDirectory, isDirectory: true)
            let contents: [URL] = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            fileURLs = contents.filter { url in
                url.pathExtension == "jack"
            }
        } else {
            fileURLs = [URL(fileURLWithPath: fileOrDirectory)]
        }

        return fileURLs
    }

    private func outFileURL(for fileURL: URL, suffix: String) -> URL {
        let oufFileName = fileURL.lastPathComponent.components(separatedBy: ".").first!.appending(suffix)
        return fileURL.deletingLastPathComponent().appendingPathComponent(oufFileName)
    }
}

JackCompiler.main()
