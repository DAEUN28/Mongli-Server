import Foundation

import SwiftJWT

struct AccessTokenClaim: Claims {
  let exp = Date(timeInterval: 36000, since: Date())
  let sub: Int
}

struct RefreshTokenClaim: Claims {
  let exp = Date(timeInterval: 1209600, since: Date())
  let sub: Int
}
