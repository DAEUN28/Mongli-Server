import Foundation

import SwiftJWT

struct TokenClaims: Claims {
  var exp: Date?
  var sub: Int
}

enum TokenType {
  case access, refresh
}
