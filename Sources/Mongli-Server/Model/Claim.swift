import Foundation

import SwiftJWT

protocol TokenClaims: Claims {
  var sub: Int { get set }
}

struct AccessTokenClaim: TokenClaims {
  let exp = Date(timeInterval: 3600, since: Date())
  var sub: Int
}

struct RefreshTokenClaim: TokenClaims {
  let exp = Date(timeInterval: 1209600, since: Date())
  var sub: Int
}
