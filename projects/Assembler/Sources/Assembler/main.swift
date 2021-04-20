import Foundation

let argv = ProcessInfo.processInfo.arguments
guard argv.count == 2, let filePath = argv.last else {
    print("Usage: Assembler file.asm")
    exit(1)
}

guard let parser = try? Parser(contentsOfFile: filePath) else {
    print("Could not open file (\(filePath))")
    exit(1)
}

let symbolTable = SymbolTable()

// 1. Create symbol tables
var address = 0
while parser.hasMoreCommands {
    switch parser.currentCommand {
    case let .label(symbol):
        symbolTable.add(symbol: symbol, address: address)
    case .address, .calculate:
        address += 1
    }
    parser.advance()
}
parser.reset()

// 2. Print binary strings
var nextVariableSymbolAddress = SymbolTable.variableSymbolStartAddress
while parser.hasMoreCommands {
    let command = parser.currentCommand
    var resolved: Command?

    switch command {
    case let .address(address):
        switch address {
        case let .symbol(symbol):
            if symbolTable.contains(symbol: symbol), let symbolAddress = symbolTable.address(for: symbol) {
                resolved = .address(.raw(symbolAddress))
            } else {
                symbolTable.add(symbol: symbol, address: nextVariableSymbolAddress)
                resolved = .address(.raw(nextVariableSymbolAddress))
                nextVariableSymbolAddress += 1
            }
        case .raw:
            resolved = command
        }
    case .label:
        break
    case .calculate:
        resolved = command
    }

    if let resolved = resolved {
        print(Code.binaryString(command: resolved))
    }

    parser.advance()
}