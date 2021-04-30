import Foundation

class CodeWriter {
    var currentVMFile: String?
    var comparisonCount = 0
    var callCount = 0

    func startConvertingVMFile(file: String) {
        currentVMFile = file.components(separatedBy: ".").first
        print("// === \(file) ===")
    }

    func writeInit() {
        print("// === Bootstrap ===")

        print("@256")
        print("D=A")
        print("@SP")
        print("M=D")

        writeCall(functionName: "Sys.init", numArgs: 0)

        print("")
    }

    func write(command: Command) {
        print("\n// \(command)")

        switch command {
        case let .arithmetic(arithmetic):
            writeArithmetic(arithmetic: arithmetic)
        case .push, .pop:
            writePushPop(command: command)
        case let .label(label):
            writeLabel(label: label)
        case let .goto(label):
            writeGoto(label: label)
        case let .if(label):
            writeIf(label: label)
        case let .function(functionName: functionName, numLocals: numLocals):
            writeFunction(functionName: functionName, numLocals: numLocals)
        case .return:
            writeReturn()
        case let .call(functionName: functionName, numArgs: numArgs):
            writeCall(functionName: functionName, numArgs: numArgs)
        }
    }

    private func makeComparisonSymbolPrefix() -> String {
        comparisonCount += 1
        return "comparison:\(comparisonCount)"
    }

    private func makeLabelSymbol(_ label: String) -> String {
        "label:\(label)"
    }

    private func makeFunctionSymbol(_ functionName: String) -> String {
        "function:\(functionName)"
    }

    private func makeReturnSymbol(functionName: String) -> String {
        callCount += 1
        return "return:\(functionName):\(callCount)"
    }

    private func writeArithmetic(arithmetic: Command.Arithmetic) {
        print("@SP")
        print("AM=M-1")

        switch arithmetic {
        case .neg, .not:
            switch arithmetic {
            case .neg:
                print("M=-M")
            case .not:
                print("M=!M")
            default:
                fatalError()
            }

            print("@SP")
            print("M=M+1")
        case .add, .sub, .and, .or:
            print("D=M")

            print("@SP")
            print("AM=M-1")

            switch arithmetic {
            case .add:
                print("M=M+D")
            case .sub:
                print("M=M-D")
            case .and:
                print("M=M&D")
            case .or:
                print("M=M|D")
            default:
                fatalError()
            }

            print("@SP")
            print("M=M+1")
        case .eq, .lt, .gt:
            print("D=M")

            print("@SP")
            print("AM=M-1")
            print("D=M-D")

            let symbolPrefix = makeComparisonSymbolPrefix()

            print("@\(symbolPrefix):true")
            switch arithmetic {
            case .eq:
                print("D;JEQ")
            case .lt:
                print("D;JLT")
            case .gt:
                print("D;JGT")
            default:
                fatalError()
            }

            print("@SP")
            print("A=M")
            print("M=0")

            print("@SP")
            print("M=M+1")

            print("@\(symbolPrefix):end")
            print("0;JMP")

            print("(\(symbolPrefix):true)")

            print("@SP")
            print("A=M")
            print("M=-1")

            print("@SP")
            print("M=M+1")

            print("(\(symbolPrefix):end)")
        }
    }

    private func writePushPop(command: Command) {
        let segment: Command.Segment
        let index: Int

        switch command {
        case let .push(segment: s, index: i):
            segment = s
            index = i
        case let .pop(segment: s, index: i):
            segment = s
            index = i
        default:
            fatalError()
        }

        switch segment {
        case .constant, .static:
            let address: String
            switch segment {
            case .constant:
                address = "\(index)"
            case .static:
                let file = currentVMFile ?? ""
                address = "\(file).\(index)"
            default:
                fatalError()
            }

            switch command {
            case .push:
                print("@\(address)")
                switch segment {
                case .constant:
                    print("D=A")
                case .static:
                    print("D=M")
                default:
                    fatalError()
                }
                print("@SP")
                print("A=M")
                print("M=D")

                print("@SP")
                print("M=M+1")
            case .pop:
                print("@SP")
                print("AM=M-1")
                print("D=M")

                print("@\(address)")
                print("M=D")
            default:
                fatalError()
            }
        case .local, .argument, .this, .that, .temp:
            switch segment {
            case .local:
                print("@LCL")
                print("D=M")
            case .argument:
                print("@ARG")
                print("D=M")
            case .this:
                print("@THIS")
                print("D=M")
            case .that:
                print("@THAT")
                print("D=M")
            case .temp:
                print("@5")
                print("D=A")
            default:
                fatalError()
            }

            switch command {
            case .push:
                print("@\(index)")
                print("A=D+A")
                print("D=M")

                print("@SP")
                print("A=M")
                print("M=D")

                print("@SP")
                print("M=M+1")
            case .pop:
                print("@\(index)")
                print("D=D+A")

                print("@R13")
                print("M=D")

                print("@SP")
                print("AM=M-1")
                print("D=M")

                print("@R13")
                print("A=M")
                print("M=D")
            default:
                fatalError()
            }
        case .pointer:
            switch command {
            case .push:
                switch index {
                case 0:
                    print("@THIS")
                case 1:
                    print("@THAT")
                default:
                    fatalError()
                }
                print("D=M")

                print("@SP")
                print("A=M")
                print("M=D")

                print("@SP")
                print("M=M+1")
            case .pop:
                print("@SP")
                print("AM=M-1")
                print("D=M")
                switch index {
                case 0:
                    print("@THIS")
                case 1:
                    print("@THAT")
                default:
                    fatalError()
                }
                print("M=D")
            default:
                fatalError()
            }
        }
    }

    private func writeLabel(label: String) {
        let symbol = makeLabelSymbol(label)
        print("(\(symbol))")
    }

    private func writeGoto(label: String) {
        let symbol = makeLabelSymbol(label)
        print("@\(symbol)")
        print("0;JMP")
    }

    private func writeIf(label: String) {
        let symbol = makeLabelSymbol(label)
        print("@SP")
        print("AM=M-1")
        print("D=M")
        print("@\(symbol)")
        print("D;JNE")
    }

    private func writeCall(functionName: String, numArgs: Int) {
        let returnSymbol = makeReturnSymbol(functionName: functionName)

        print("@\(returnSymbol)")
        print("D=A")
        print("@SP")
        print("A=M")
        print("M=D")
        print("@SP")
        print("M=M+1")

        print("@LCL")
        print("D=M")
        print("@SP")
        print("A=M")
        print("M=D")
        print("@SP")
        print("M=M+1")

        print("@ARG")
        print("D=M")
        print("@SP")
        print("A=M")
        print("M=D")
        print("@SP")
        print("M=M+1")

        print("@THIS")
        print("D=M")
        print("@SP")
        print("A=M")
        print("M=D")
        print("@SP")
        print("M=M+1")

        print("@THAT")
        print("D=M")
        print("@SP")
        print("A=M")
        print("M=D")
        print("@SP")
        print("M=M+1")

        print("@SP")
        print("D=M")
        print("@\(numArgs)")
        print("D=D-A")
        print("@5")
        print("D=D-A")
        print("@ARG")
        print("M=D")

        print("@SP")
        print("D=M")
        print("@LCL")
        print("M=D")

        let functionSymbol = makeFunctionSymbol(functionName)
        print("@\(functionSymbol)")
        print("0;JMP")

        print("(\(returnSymbol))")
    }

    private func writeReturn() {
        print("@LCL")
        print("D=M")
        print("@R13") // FRAME
        print("M=D")

        print("@5")
        print("A=D-A")
        print("D=M")
        print("@R14") // RET
        print("M=D")

        print("@SP")
        print("AM=M-1")
        print("D=M")
        print("@ARG")
        print("A=M")
        print("M=D")

        print("D=A")
        print("@SP")
        print("M=D+1")

        print("@R13")
        print("D=M")
        print("A=D-1")
        print("D=M")
        print("@THAT")
        print("M=D")

        print("@R13")
        print("D=M")
        print("@2")
        print("A=D-A")
        print("D=M")
        print("@THIS")
        print("M=D")

        print("@R13")
        print("D=M")
        print("@3")
        print("A=D-A")
        print("D=M")
        print("@ARG")
        print("M=D")

        print("@R13")
        print("D=M")
        print("@4")
        print("A=D-A")
        print("D=M")
        print("@LCL")
        print("M=D")

        print("@R14")
        print("A=M")
        print("0;JMP")
    }

    private func writeFunction(functionName: String, numLocals: Int) {
        let functionSymbol = makeFunctionSymbol(functionName)
        print("(\(functionSymbol))")

        for _ in 0..<numLocals {
            print("@SP")
            print("A=M")
            print("M=0")

            print("@SP")
            print("M=M+1")
        }
    }
}
