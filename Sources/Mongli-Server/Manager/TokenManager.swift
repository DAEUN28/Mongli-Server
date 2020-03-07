import Foundation

import Kitura
import SwiftJWT

final class TokenManager {
  private let jwtSigner: JWTSigner
  private let jwtVerifier: JWTVerifier
  let jwtEncoder: JWTEncoder
  let jwtDecoder: JWTDecoder

  init() {
    jwtSigner = JWTSigner.hs256(key: SecurityInformation.privateKey)
    jwtVerifier = JWTVerifier.hs256(key: SecurityInformation.privateKey)
    jwtEncoder = JWTEncoder(jwtSigner: jwtSigner)
    jwtDecoder = JWTDecoder(jwtVerifier: jwtVerifier)
  }

  func createToken<T: Claims>(_ claim: T) -> String? {
    var jwt = JWT(header: Header(), claims: claim)
    return try? jwt.sign(using: self.jwtSigner)
  }

  func isVerified<T: Claims>(_ token: String, type: T) -> Bool {
    return JWT<T>.verify(token, using: jwtVerifier)
  }
}
