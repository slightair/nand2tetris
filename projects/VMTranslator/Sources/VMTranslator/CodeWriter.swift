import Foundation

class CodeWriter {
    var currentVMFile: String?
    var comparisonCount = 0

    func startConvertingVMFile(file: String) {
        currentVMFile = file
        print("// === \(file) ===")
    }

    func write(command: Command) {
        switch command {
        case let .arithmetic(arithmetic):
            writeArithmetic(arithmetic: arithmetic)
        case let .push(segment: segment, index: index):
            writePushPop(command: command, segment: segment, index: index)
        case let .pop(segment: segment, index: index):
            writePushPop(command: command, segment: segment, index: index)
        default:
            fatalError("Not yet implemented: '\(command)'")
        }
    }

    private func writeArithmetic(arithmetic: Command.Arithmetic) {
        print("\n// \(arithmetic)")

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

            guard let file = currentVMFile else {
                fatalError()
            }
            let comparisonSymbol = "$\(file):COMP\(comparisonCount)"

            print("@\(comparisonSymbol):TRUE")
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

            print("@\(comparisonSymbol):END")
            print("0;JMP")

            print("(\(comparisonSymbol):TRUE)")

            print("@SP")
            print("A=M")
            print("M=-1")

            print("@SP")
            print("M=M+1")

            print("(\(comparisonSymbol):END)")

            comparisonCount += 1
        }
    }

    private func writePushPop(command: Command, segment: Command.Segment, index: Int) {
        print("\n// \(command)")

        switch segment {
        case .constant, .static:
            let address: String
            switch segment {
            case .constant:
                address = "\(index)"
            case .static:
                guard let file = currentVMFile else {
                    fatalError()
                }
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
}
