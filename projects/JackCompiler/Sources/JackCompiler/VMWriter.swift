import Foundation

class VMWriter {
    private var outputStream: FileHandlerOutputStream

    init(fileURL: URL) throws {
        outputStream = try FileHandlerOutputStream(fileURL: fileURL)
    }

    private func writeCommand(_ command: String, comment: String?) {
        let suffix = comment.flatMap {
            " // \($0)"
        } ?? ""
        print(command, suffix, to: &outputStream)
    }

    func writePush(segment: Segment, index: Int, comment: String? = nil) {
        writeCommand("push \(segment) \(index)", comment: comment)
    }

    func writePop(segment: Segment, index: Int, comment: String? = nil) {
        writeCommand("pop \(segment) \(index)", comment: comment)
    }

    func writeArithmetic(_ arithmetic: Arithmetic, comment: String? = nil) {
        writeCommand(arithmetic.rawValue, comment: comment)
    }

    func writeLabel(label: String, comment: String? = nil) {
        writeCommand("label \(label)", comment: comment)
    }

    func writeGoto(label: String, comment: String? = nil) {
        writeCommand("goto \(label)", comment: comment)
    }

    func writeIf(label: String, comment: String? = nil) {
        writeCommand("if-goto \(label)", comment: comment)
    }

    func writeCall(name: String, numArgs: Int, comment: String? = nil) {
        writeCommand("call \(name) \(numArgs)", comment: comment)
    }

    func writeFunction(name: String, numLocals: Int, comment: String? = nil) {
        writeCommand("function \(name) \(numLocals)", comment: comment)
    }

    func writeReturn(comment: String? = nil) {
        writeCommand("return", comment: comment)
    }
}
