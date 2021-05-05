import Foundation

class XMLWriter {
    private var outputStream: FileHandlerOutputStream
    private var level = 0

    init(fileURL: URL) throws {
        outputStream = try FileHandlerOutputStream(fileURL: fileURL)
    }

    func writeOpen(name: String) {
        let indent = String(repeating: "\t", count: level)
        level += 1
        print("\(indent)<\(name)>", to: &outputStream)
    }

    func writeClose(name: String) {
        assert(level > 0)

        level -= 1
        let indent = String(repeating: "\t", count: level)
        print("\(indent)</\(name)>", to: &outputStream)
    }

    func writeElement(name: String, innerText: String) {
        let escapedInnerText = CFXMLCreateStringByEscapingEntities(nil, innerText as NSString, nil) as String
        let indent = String(repeating: "\t", count: level)
        print("\(indent)<\(name)> \(escapedInnerText) </\(name)>", to: &outputStream)
    }
}
