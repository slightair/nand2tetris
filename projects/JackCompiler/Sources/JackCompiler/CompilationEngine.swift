import Foundation

class CompilationEngine {
    private let tokenizer: JackTokenizer
    private let symbolTable: SymbolTable
    private let xmlWriter: XMLWriter?
    private let vmWriter: VMWriter?

    private var className: String?
    private var labelCounter = 0

    init(inFileURL: URL, outXMLFileURL: URL? = nil, outVMFileURL: URL? = nil) throws {
        tokenizer = try JackTokenizer(fileURL: inFileURL)
        symbolTable = SymbolTable()

        if let outFileURL = outXMLFileURL {
            xmlWriter = try XMLWriter(fileURL: outFileURL)
        } else {
            xmlWriter = nil
        }

        if let outFileURL = outVMFileURL {
            vmWriter = try VMWriter(fileURL: outFileURL)
        } else {
            vmWriter = nil
        }
    }

    func compileClass() {
        open("class")
        keyword(.class)
        let nameToken = className()
        className = nameToken.value
        symbol("{")
        while current().isKeyword(in: [.static, .field]) {
            compileClassVarDec()
        }
        while current().isKeyword(in: [.constructor, .function, .method]) {
            compileSubroutine()
        }
        symbol("}")
        close("class")
    }

    func compileClassVarDec() {
        open("classVarDec")
        let kindToken = keyword(in: [.static, .field])
        let typeToken = type()
        var nameToken = varName()
        registerSymbol(nameToken: nameToken, typeToken: typeToken, kindToken: kindToken)
        while current().isSymbol(",") {
            symbol(",")
            nameToken = varName()
            registerSymbol(nameToken: nameToken, typeToken: typeToken, kindToken: kindToken)
        }
        symbol(";")
        close("classVarDec")
    }

    func compileSubroutine() {
        symbolTable.startSubroutine()
        open("subroutineDec")
        let subroutineToken = keyword(in: [.constructor, .function, .method])
        voidOrType()
        let nameToken = subroutineName()
        symbol("(")
        compileParameterList(isMethod: subroutineToken == .keyword(.method))
        symbol(")")
        open("subroutineBody")
        symbol("{")
        while current().isKeyword(.var) {
            compileVarDec()
        }
        let numLocals = symbolTable.varCount(kind: .var)
        vmWriter?.writeFunction(name: "\(className!).\(nameToken.value)", numLocals: numLocals)

        if subroutineToken == .keyword(.constructor) {
            let numFields = symbolTable.varCount(kind: .field)
            vmWriter?.writePush(segment: .constant, index: numFields)
            vmWriter?.writeCall(name: "Memory.alloc", numArgs: 1)
            vmWriter?.writePop(segment: .pointer, index: 0)
        }

        if subroutineToken == .keyword(.method) {
            vmWriter?.writePush(segment: .argument, index: 0)
            vmWriter?.writePop(segment: .pointer, index: 0)
        }

        compileStatements()
        symbol("}")
        close("subroutineBody")
        close("subroutineDec")
    }

    func compileParameterList(isMethod: Bool) {
        open("parameterList")
        if current().isType() {
            var typeToken = type()
            var nameToken = varName()
            registerSymbol(nameToken: nameToken, typeToken: typeToken, kind: .arg, isMethod: isMethod)
            while current().isSymbol(",") {
                symbol(",")
                typeToken = type()
                nameToken = varName()
                registerSymbol(nameToken: nameToken, typeToken: typeToken, kind: .arg, isMethod: isMethod)
            }
        }
        close("parameterList")
    }

    func compileVarDec() {
        open("varDec")
        keyword(.var)
        let typeToken = type()
        var nameToken = varName()
        registerSymbol(nameToken: nameToken, typeToken: typeToken, kind: .var)
        while current().isSymbol(",") {
            symbol(",")
            nameToken = varName()
            registerSymbol(nameToken: nameToken, typeToken: typeToken, kind: .var)
        }
        symbol(";")
        close("varDec")
    }

    func compileStatements() {
        open("statements")
        while current().isKeyword(in: [.let, .if, .while, .do, .return]) {
            switch current() {
            case .keyword(.let):
                compileLet()
            case .keyword(.if):
                compileIf()
            case .keyword(.while):
                compileWhile()
            case .keyword(.do):
                compileDo()
            case .keyword(.return):
                compileReturn()
            default:
                fatalError()
            }
        }
        close("statements")
    }

    func compileDo() {
        open("doStatement")
        keyword(.do)
        compileSubroutineCall()
        vmWriter?.writePop(segment: .temp, index: 0)
        symbol(";")
        close("doStatement")
    }

    func compileLet() {
        open("letStatement")
        keyword(.let)

        let isArray: Bool
        let nameToken = varName()
        if current().isSymbol("[") {
            isArray = true
            symbol("[")
            compileExpression()
            symbol("]")
            resolveSymbol(nameToken: nameToken, command: .push)
            vmWriter?.writeArithmetic(.add)
        } else {
            isArray = false
        }
        symbol("=")
        compileExpression()

        if isArray {
            vmWriter?.writePop(segment: .temp, index: 0)
            vmWriter?.writePop(segment: .pointer, index: 1)
            vmWriter?.writePush(segment: .temp, index: 0)
            vmWriter?.writePop(segment: .that, index: 0)
        } else {
            resolveSymbol(nameToken: nameToken, command: .pop)
        }

        symbol(";")
        close("letStatement")
    }

    func compileWhile() {
        let label1 = makeLabel()
        let label2 = makeLabel()
        open("whileStatement")
        keyword(.while)
        vmWriter?.writeLabel(label: label1)
        symbol("(")
        compileExpression()
        vmWriter?.writeArithmetic(.not)
        vmWriter?.writeIf(label: label2)
        symbol(")")
        symbol("{")
        compileStatements()
        vmWriter?.writeGoto(label: label1)
        vmWriter?.writeLabel(label: label2)
        symbol("}")
        close("whileStatement")
    }

    func compileReturn() {
        open("returnStatement")
        keyword(.return)
        if current().canBeTerm() {
            compileExpression()
        } else {
            vmWriter?.writePush(segment: .constant, index: 0)
        }
        vmWriter?.writeReturn()
        symbol(";")
        close("returnStatement")
    }

    func compileIf() {
        let label1 = makeLabel()
        let label2 = makeLabel()
        open("ifStatement")
        keyword(.if)
        symbol("(")
        compileExpression()
        vmWriter?.writeArithmetic(.not)
        vmWriter?.writeIf(label: label1)
        symbol(")")
        symbol("{")
        compileStatements()
        vmWriter?.writeGoto(label: label2)
        symbol("}")
        vmWriter?.writeLabel(label: label1)
        if current().isKeyword(.else) {
            keyword(.else)
            symbol("{")
            compileStatements()
            symbol("}")
        }
        vmWriter?.writeLabel(label: label2)
        close("ifStatement")
    }

    func compileExpression() {
        open("expression")
        compileTerm()
        while current().isOp() {
            let opToken = op()
            compileTerm()
            switch opToken.value {
            case "+":
                vmWriter?.writeArithmetic(.add)
            case "-":
                vmWriter?.writeArithmetic(.sub)
            case "*":
                vmWriter?.writeCall(name: "Math.multiply", numArgs: 2)
            case "/":
                vmWriter?.writeCall(name: "Math.divide", numArgs: 2)
            case "&":
                vmWriter?.writeArithmetic(.and)
            case "|":
                vmWriter?.writeArithmetic(.or)
            case "<":
                vmWriter?.writeArithmetic(.lt)
            case ">":
                vmWriter?.writeArithmetic(.gt)
            case "=":
                vmWriter?.writeArithmetic(.eq)
            default:
                fatalError()
            }
        }
        close("expression")
    }

    func compileTerm() {
        open("term")
        switch current() {
        case .integerConstant:
            let integer = integerConstant()
            vmWriter?.writePush(segment: .constant, index: Int(integer.value)!)
        case .stringConstant:
            let string = stringConstant()
            vmWriter?.writePush(segment: .constant, index: string.value.count)
            vmWriter?.writeCall(name: "String.new", numArgs: 1)
            for char in string.value.utf8 {
                vmWriter?.writePush(segment: .constant, index: Int(char))
                vmWriter?.writeCall(name: "String.appendChar", numArgs: 2)
            }
        case .keyword(.true):
            keyword(.true)
            vmWriter?.writePush(segment: .constant, index: 1)
            vmWriter?.writeArithmetic(.neg)
        case .keyword(.false):
            keyword(.false)
            vmWriter?.writePush(segment: .constant, index: 0)
        case .keyword(.null):
            keyword(.null)
            vmWriter?.writePush(segment: .constant, index: 0)
        case .keyword(.this):
            keyword(.this)
            vmWriter?.writePush(segment: .pointer, index: 0)
        case .identifier:
            if next().isSymbol("[") {
                let arrayToken = identifier()
                symbol("[")
                compileExpression()
                symbol("]")
                resolveSymbol(nameToken: arrayToken, command: .push)
                vmWriter?.writeArithmetic(.add)
                vmWriter?.writePop(segment: .pointer, index: 1)
                vmWriter?.writePush(segment: .that, index: 0)
            } else if next().isSymbol("(") || next().isSymbol(".") {
                compileSubroutineCall()
            } else {
                let nameToken = identifier()
                resolveSymbol(nameToken: nameToken, command: .push)
            }
        case .symbol("("):
            symbol("(")
            compileExpression()
            symbol(")")
        case .symbol("-"):
            symbol("-")
            compileTerm()
            vmWriter?.writeArithmetic(.neg)
        case .symbol("~"):
            symbol("~")
            compileTerm()
            vmWriter?.writeArithmetic(.not)
        default:
            fatalError()
        }
        close("term")
    }

    func compileExpressionList() -> Int {
        open("expressionList")
        var numArgs = 0
        if current().canBeTerm() {
            compileExpression()
            numArgs += 1
            while current().isSymbol(",") {
                symbol(",")
                compileExpression()
                numArgs += 1
            }
        }
        close("expressionList")
        return numArgs
    }

    private func subroutineAttribute(nameToken1: Token, nameToken2: Token?) -> (name: String, isMethod: Bool, segment: Segment?, index: Int?) {
        let name: String
        let isMethod: Bool
        var segment: Segment?
        var index: Int?

        if let nameToken2 = nameToken2 {
            if let klass = symbolTable.typeOf(name: nameToken1.value),
               let idx = symbolTable.indexOf(name: nameToken1.value),
               let kind = symbolTable.kindOf(name: nameToken1.value) {
                isMethod = true
                name = "\(klass).\(nameToken2.value)"
                switch kind {
                case .static:
                    segment = .static
                case .field:
                    segment = .this
                case .arg:
                    segment = .argument
                case .var:
                    segment = .local
                }
                index = idx
            } else {
                isMethod = false
                name = "\(nameToken1.value).\(nameToken2.value)"
            }
        } else {
            isMethod = true
            name = "\(className!).\(nameToken1.value)"
            segment = .pointer
            index = 0
        }

        return (name: name, isMethod: isMethod, segment: segment, index: index)
    }

    private func compileSubroutineCall() {
        let nameToken1 = identifier() // subroutineName | className | varName
        var nameToken2: Token?

        if current().isSymbol(".") {
            symbol(".")
            nameToken2 = subroutineName()
        }

        let callee = subroutineAttribute(nameToken1: nameToken1, nameToken2: nameToken2)
        if callee.isMethod, let segment = callee.segment, let index = callee.index {
            vmWriter?.writePush(segment: segment, index: index)
        }

        symbol("(")
        var numArgs = compileExpressionList()
        if callee.isMethod {
            numArgs += 1
        }
        vmWriter?.writeCall(name: callee.name, numArgs: numArgs)
        symbol(")")
    }
}

extension CompilationEngine {
    private func open(_ name: String) {
        xmlWriter?.writeOpen(name: name)
    }

    private func close(_ name: String) {
        xmlWriter?.writeClose(name: name)
    }

    private func current() -> Token {
        tokenizer.currentToken
    }

    private func next() -> Token {
        tokenizer.nextToken
    }

    private func advance(validation: (Token) -> Void) -> Token {
        let token = current()
        validation(token)
        xmlWriter?.writeToken(token)
        tokenizer.advance()
        return token
    }

    @discardableResult
    private func keyword(_ keyword: Keyword, line: UInt = #line) -> Token {
        advance { token in
            assert(token.isKeyword(keyword), line: line)
        }
    }

    @discardableResult
    private func keyword(in keywords: Set<Keyword>, line: UInt = #line) -> Token {
        advance { token in
            assert(token.isKeyword(in: keywords), line: line)
        }
    }

    @discardableResult
    private func identifier(line: UInt = #line) -> Token {
        advance { token in
            assert(token.name == "identifier", line: line)
        }
    }

    @discardableResult
    private func className(line: UInt = #line) -> Token {
        identifier(line: line)
    }

    @discardableResult
    private func subroutineName(line: UInt = #line) -> Token {
        identifier(line: line)
    }

    @discardableResult
    private func varName(line: UInt = #line) -> Token {
        identifier(line: line)
    }

    @discardableResult
    private func symbol(_ symbol: String, line: UInt = #line) -> Token {
        advance { token in
            assert(token.isSymbol(symbol), line: line)
        }
    }

    @discardableResult
    private func type(line: UInt = #line) -> Token {
        advance { token in
            assert(token.isType(), line: line)
        }
    }

    @discardableResult
    private func voidOrType(line: UInt = #line) -> Token {
        advance { token in
            assert(token.isKeyword(.void) || token.isType(), line: line)
        }
    }

    @discardableResult
    private func op(line: UInt = #line) -> Token {
        advance { token in
            assert(token.isOp(), line: line)
        }
    }

    @discardableResult
    private func integerConstant(line: UInt = #line) -> Token {
        advance { token in
            assert(token.name == "integerConstant", line: line)
        }
    }

    @discardableResult
    private func stringConstant(line: UInt = #line) -> Token {
        advance { token in
            assert(token.name == "stringConstant", line: line)
        }
    }

    private func registerSymbol(nameToken: Token, typeToken: Token, kind: SymbolTable.Kind, isMethod: Bool = false) {
        symbolTable.define(name: nameToken.value, type: typeToken.value, kind: kind, isMethod: isMethod)
    }

    private func registerSymbol(nameToken: Token, typeToken: Token, kindToken: Token) {
        let kind: SymbolTable.Kind
        switch kindToken {
        case .keyword(.static):
            kind = .static
        case .keyword(.field):
            kind = .field
        default:
            fatalError()
        }
        registerSymbol(nameToken: nameToken, typeToken: typeToken, kind: kind)
    }

    enum Command {
        case push
        case pop
    }

    private func resolveSymbol(nameToken: Token, command: Command) {
        guard let kind = symbolTable.kindOf(name: nameToken.value) else {
            fatalError("Unknown symbol: \(nameToken.value)")
        }

        let segment: Segment
        switch kind {
        case .static:
            segment = .static
        case .field:
            segment = .this
        case .arg:
            segment = .argument
        case .var:
            segment = .local
        }

        guard let index = symbolTable.indexOf(name: nameToken.value) else {
            fatalError("Unknown symbol: \(nameToken.value)")
        }

        switch command {
        case .push:
            vmWriter?.writePush(segment: segment, index: index)
        case .pop:
            vmWriter?.writePop(segment: segment, index: index)
        }
    }

    private func makeLabel() -> String {
        let label = "L\(labelCounter)"
        labelCounter += 1
        return label
    }
}

extension XMLWriter {
    func writeToken(_ token: Token) {
        writeElement(name: token.name, innerText: token.value)
    }
}

extension Token {
    func isSymbol(_ symbol: String) -> Bool {
        self == .symbol(symbol)
    }

    func isSymbol(in symbols: Set<String>) -> Bool {
        if case let .symbol(symbol) = self, symbols.contains(symbol) {
            return true
        }
        return false
    }

    func isKeyword(_ keyword: Keyword) -> Bool {
        self == .keyword(keyword)
    }

    func isKeyword(in keywords: Set<Keyword>) -> Bool {
        if case let .keyword(keyword) = self, keywords.contains(keyword) {
            return true
        }
        return false
    }

    func isType() -> Bool {
        switch self {
        case .keyword(.int), .keyword(.char), .keyword(.boolean), .identifier:
            return true
        default:
            return false
        }
    }

    func canBeTerm() -> Bool {
        switch self {
        case .integerConstant, .stringConstant, .identifier, .symbol("("):
            return true
        default:
            return isKeywordConstant() || isUnaryOp()
        }
    }

    func isOp() -> Bool {
        isSymbol(in: ["+", "-", "*", "/", "&", "|", "<", ">", "="])
    }

    func isUnaryOp() -> Bool {
        isSymbol(in: ["-", "~"])
    }

    func isKeywordConstant() -> Bool {
        isKeyword(in: [.true, .false, .null, .this])
    }
}
