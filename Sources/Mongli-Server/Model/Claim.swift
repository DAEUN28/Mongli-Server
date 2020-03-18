import Foundation

import SwiftJWT

struct TokenClaims: Claims {
  var exp: Date?
  var id: Int
  var name: String
}

enum TokenType {
  case access, refresh
}
