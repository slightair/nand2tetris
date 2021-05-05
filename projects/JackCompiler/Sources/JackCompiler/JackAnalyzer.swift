import Foundation

struct JackAnalyzer {
    enum AnalyzerError: Error {
        case fileNotFound
    }

    private static func targetFileURLs(fileOrDirectory: String) throws -> [URL] {
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: fileOrDirectory, isDirectory: &isDirectory) else {
            throw AnalyzerError.fileNotFound
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

    private static func tokensOutFileURL(for fileURL: URL) -> URL {
        let oufFileName = fileURL.lastPathComponent.components(separatedBy: ".").first!.appending("T.xml")
        return fileURL.deletingLastPathComponent().appendingPathComponent(oufFileName)
    }

    private static func parseOutFileURL(for fileURL: URL) -> URL {
        let oufFileName = fileURL.lastPathComponent.components(separatedBy: ".").first!.appending(".xml")
        return fileURL.deletingLastPathComponent().appendingPathComponent(oufFileName)
    }

    static func tokenize(fileOrDirectory: String) throws {
        let fileURLs = try targetFileURLs(fileOrDirectory: fileOrDirectory)
        try fileURLs.forEach { fileURL in
            let xmlWriter = try XMLWriter(fileURL: tokensOutFileURL(for: fileURL))
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

    static func parse(fileOrDirectory: String) throws {
        let fileURLs = try targetFileURLs(fileOrDirectory: fileOrDirectory)
        try fileURLs.forEach { fileURL in
            let engine = try CompilationEngine(inURL: fileURL, outURL: parseOutFileURL(for: fileURL))
            engine.compileClass()
        }
    }

}
