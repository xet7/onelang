import Foundation

enum TokenKind {
    case number, identifier, operator_, string_
}

class Token {
  var kind: TokenKind?
  var value: String?

  init(kind: TokenKind?, value: String?) {
      self.value = value
      self.kind = kind
  }
}

class ExprLangLexer {
  var offset: Int = 0
  var tokens: [Token?]? = [Token]()
  var expression: String?
  var operators: [String?]?

  init(expression: String?, operators: [String?]?) throws {
      self.operators = operators
      self.expression = expression
      if !(try self.tryToReadNumber()) {
          _ = self.tryToReadOperator()
          _ = try self.tryToReadLiteral()
      }
      
      while self.hasMoreToken() {
          if !(self.tryToReadOperator()) {
              try self.fail(message: "expected operator here")
          }
          
          if !(try self.tryToReadLiteral()) {
              try self.fail(message: "expected literal here")
          }
      }
  }

  func fail(message: String) throws -> Void {
      var end_offset = self.offset + 30
      if end_offset > self.expression!.count {
          end_offset = self.expression!.count
      }
      let context = String(self.expression![self.expression!.index(self.expression!.startIndex, offsetBy: self.offset) ..< self.expression!.index(self.expression!.startIndex, offsetBy: end_offset)]) + "..."
      throw OneError.RuntimeError("TokenizerException: \(message) at '\(context)' (offset: \(self.offset))")
  }

  func hasMoreToken() -> Bool {
      self.skipWhitespace()
      return !(self.eof())
  }

  func add(kind: TokenKind?, value: String?) -> Void {
      self.tokens!.append(Token(kind: kind, value: value))
      self.offset += value!.count
  }

  func tryToMatch(pattern: String?) -> String? {
      let matches = OneRegex.matchFromIndex(pattern: pattern, input: self.expression!, offset: self.offset)
      return matches == nil ? nil : matches![0]
  }

  func tryToReadOperator() -> Bool {
      self.skipWhitespace()
      for op in self.operators! {
          if String(self.expression![self.expression!.index(self.expression!.startIndex, offsetBy: self.offset) ..< self.expression!.endIndex]).hasPrefix(op!) {
              self.add(kind: TokenKind.operator_, value: op)
              return true
          }
      }
      return false
  }

  func tryToReadNumber() throws -> Bool {
      self.skipWhitespace()
      
      let number = self.tryToMatch(pattern: "[+-]?(\\d*\\.\\d+|\\d+\\.\\d+|0x[0-9a-fA-F_]+|0b[01_]+|[0-9_]+)")
      if number == nil {
          return false
      }
      
      self.add(kind: TokenKind.number, value: number)
      
      if self.tryToMatch(pattern: "[0-9a-zA-Z]") != nil {
          try self.fail(message: "invalid character in number")
      }
      
      return true
  }

  func tryToReadIdentifier() -> Bool {
      self.skipWhitespace()
      let identifier = self.tryToMatch(pattern: "[a-zA-Z_][a-zA-Z0-9_]*")
      if identifier == nil {
          return false
      }
      
      self.add(kind: TokenKind.identifier, value: identifier)
      return true
  }

  func tryToReadString() -> Bool {
      self.skipWhitespace()
      
      var match = self.tryToMatch(pattern: "\'(\\\\\'|[^\'])*\'")
      if match == nil {
          match = self.tryToMatch(pattern: "\"(\\\\\"|[^\"])*\"")
      }
      if match == nil {
          return false
      }
      
      var str = String(match![match!.index(match!.startIndex, offsetBy: 1) ..< match!.index(match!.startIndex, offsetBy: 1 + match!.count - 2)])
      str = String(match![match!.index(match!.startIndex, offsetBy: 0)]) == "\'" ? str.replacingOccurrences(of: "\\\'", with: "\'") : str.replacingOccurrences(of: "\\\"", with: "\"")
      self.tokens!.append(Token(kind: TokenKind.string_, value: str))
      self.offset += match!.count
      return true
  }

  func eof() -> Bool {
      return self.offset >= self.expression!.count
  }

  func skipWhitespace() -> Void {
      while !(self.eof()) {
          let c = String(self.expression![self.expression!.index(self.expression!.startIndex, offsetBy: self.offset)])
          if c == " " || c == "\n" || c == "\t" || c == "\r" {
              self.offset += 1
          } else {
              break
          }
      }
  }

  func tryToReadLiteral() throws -> Bool {
      let success = try (self.tryToReadIdentifier() || (try self.tryToReadNumber()) || (try self.tryToReadString()))
      return success
  }
}

class TestClass {
  func testMethod() throws -> Void {
      let lexer = try ExprLangLexer(expression: "1+2", operators: ["+"])
      var result = ""
      for token in lexer.tokens! {
          if result != "" {
              result += ", "
          }
          result += token!.value!
      }
      
      print("[\(lexer.tokens!.count)]: \(result)")
  }
}

try TestClass().testMethod()