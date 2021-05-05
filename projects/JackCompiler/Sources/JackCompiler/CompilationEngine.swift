import Foundation

class CompilationEngine {
    let xmlWriter: XMLWriter
    let tokenizer: JackTokenizer

    init(inURL: URL, outURL: URL) throws {
        xmlWriter = try XMLWriter(fileURL: outURL)
        tokenizer = try JackTokenizer(fileURL: inURL)
    }

    func compileClass() {
        open("class")
        keyword(.class)
        className()
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
        keyword(in: [.static, .field])
        type()
        varName()
        while current().isSymbol(",") {
            symbol(",")
            varName()
        }
        symbol(";")
        close("classVarDec")
    }

    func compileSubroutine() {
        open("subroutineDec")
        keyword(in: [.constructor, .function, .method])
        voidOrType()
        subroutineName()
        symbol("(")
        compileParameterList()
        symbol(")")
        open("subroutineBody")
        symbol("{")
        while current().isKeyword(.var) {
            compileVarDec()
        }
        compileStatements()
        symbol("}")
        close("subroutineBody")
        close("subroutineDec")
    }

    func compileParameterList() {
        open("parameterList")
        if current().isType() {
            type()
            varName()
            while current().isSymbol(",") {
                symbol(",")
                type()
                varName()
            }
        }
        close("parameterList")
    }

    func compileVarDec() {
        open("varDec")
        keyword(.var)
        type()
        varName()
        while current().isSymbol(",") {
            symbol(",")
            varName()
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
        symbol(";")
        close("doStatement")
    }

    func compileLet() {
        open("letStatement")
        keyword(.let)
        varName()
        if current().isSymbol("[") {
            symbol("[")
            compileExpression()
            symbol("]")
        }
        symbol("=")
        compileExpression()
        symbol(";")
        close("letStatement")
    }

    func compileWhile() {
        open("whileStatement")
        keyword(.while)
        symbol("(")
        compileExpression()
        symbol(")")
        symbol("{")
        compileStatements()
        symbol("}")
        close("whileStatement")
    }

    func compileReturn() {
        open("returnStatement")
        keyword(.return)
        if current().canBeTerm() {
            compileExpression()
        }
        symbol(";")
        close("returnStatement")
    }

    func compileIf() {
        open("ifStatement")
        keyword(.if)
        symbol("(")
        compileExpression()
        symbol(")")
        symbol("{")
        compileStatements()
        symbol("}")
        if current().isKeyword(.else) {
            keyword(.else)
            symbol("{")
            compileStatements()
            symbol("}")
        }
        close("ifStatement")
    }

    func compileExpression() {
        open("expression")
        compileTerm()
        while current().isOp() {
            op()
            compileTerm()
        }
        close("expression")
    }

    func compileTerm() {
        open("term")
        switch current() {
        case .integerConstant:
            integerConstant()
        case .stringConstant:
            stringConstant()
        case .keyword(.true):
            keyword(.true)
        case .keyword(.false):
            keyword(.false)
        case .keyword(.null):
            keyword(.null)
        case .keyword(.this):
            keyword(.this)
        case .identifier:
            if next().isSymbol("[") {
                identifier()
                symbol("[")
                compileExpression()
                symbol("]")
            } else if next().isSymbol("(") || next().isSymbol(".") {
                compileSubroutineCall()
            } else {
                identifier()
            }
        case .symbol("("):
            symbol("(")
            compileExpression()
            symbol(")")
        case .symbol("-"):
            symbol("-")
            compileTerm()
        case .symbol("~"):
            symbol("~")
            compileTerm()
        default:
            fatalError()
        }
        close("term")
    }

    func compileExpressionList() {
        open("expressionList")
        if current().canBeTerm() {
            compileExpression()
            while current().isSymbol(",") {
                symbol(",")
                compileExpression()
            }
        }
        close("expressionList")
    }

    private func compileSubroutineCall() {
        identifier() // subroutineName | className | varName
        if current().isSymbol(".") {
            symbol(".")
            subroutineName()
        }
        symbol("(")
        compileExpressionList()
        symbol(")")
    }
}

extension CompilationEngine {
    private func open(_ name: String) {
        xmlWriter.writeOpen(name: name)
    }

    private func close(_ name: String) {
        xmlWriter.writeClose(name: name)
    }

    private func current() -> Token {
        tokenizer.currentToken
    }

    private func next() -> Token {
        tokenizer.nextToken
    }

    private func advance(validation: (Token) -> Void) {
        let token = current()
        validation(token)
        xmlWriter.writeToken(token)
        tokenizer.advance()
    }

    private func keyword(_ keyword: Keyword, line: UInt = #line) {
        advance { token in
            assert(token.isKeyword(keyword), line: line)
        }
    }

    private func keyword(in keywords: Set<Keyword>, line: UInt = #line) {
        advance { token in
            assert(token.isKeyword(in: keywords), line: line)
        }
    }

    private func identifier(line: UInt = #line) {
        advance { token in
            assert(token.name == "identifier", line: line)
        }
    }

    private func className(line: UInt = #line) {
        identifier(line: line)
    }

    private func subroutineName(line: UInt = #line) {
        identifier(line: line)
    }

    private func varName(line: UInt = #line) {
        identifier(line: line)
    }

    private func symbol(_ symbol: String, line: UInt = #line) {
        advance { token in
            assert(token.isSymbol(symbol), line: line)
        }
    }

    private func type(line: UInt = #line) {
        advance { token in
            assert(token.isType(), line: line)
        }
    }

    private func voidOrType(line: UInt = #line) {
        advance { token in
            assert(token.isKeyword(.void) || token.isType(), line: line)
        }
    }

    private func op(line: UInt = #line) {
        advance { token in
            assert(token.isOp(), line: line)
        }
    }

    private func integerConstant(line: UInt = #line) {
        advance { token in
            assert(token.name == "integerConstant", line: line)
        }
    }

    private func stringConstant(line: UInt = #line) {
        advance { token in
            assert(token.name == "stringConstant", line: line)
        }
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
