import Foundation

let argv = ProcessInfo.processInfo.arguments
guard argv.count > 1, let path = argv.last else {
    print("Usage: VMTranslator <file.vm or directory>")
    exit(1)
}

var withoutBootstrap = false
if argv.count > 2, argv[1] == "--without-bootstrap" {
    withoutBootstrap = true
}

var isDirectory: ObjCBool = false
guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
    print("File not exists")
    exit(1)
}

let fileURLs: [URL]
if isDirectory.boolValue {
    let directoryURL = URL(fileURLWithPath: path, isDirectory: true)
    let contents: [URL] = (try? FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)) ?? []
    fileURLs = contents.filter { url in
        url.pathExtension == "vm"
    }
} else {
    fileURLs = [URL(fileURLWithPath: path)]
}

let codeWriter = CodeWriter()

if !withoutBootstrap {
    codeWriter.writeInit()
}

fileURLs.forEach { fileURL in
    let filePath = fileURL.path
    guard let parser = try? Parser(contentsOfFile: filePath) else {
        print("Could not open file (\(filePath))")
        exit(1)
    }

    codeWriter.startConvertingVMFile(file: fileURL.lastPathComponent)

    while parser.hasMoreCommands {
        codeWriter.write(command: parser.currentCommand)
        parser.advance()
    }
}
