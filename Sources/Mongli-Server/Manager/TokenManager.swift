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

  func createToken<T: TokenClaims>(_ claim: T) -> String? {
    var jwt = JWT(header: Header(), claims: claim)
    return try? jwt.sign(using: self.jwtSigner)
  }

  func isVaildate<T: TokenClaims>(_ token: String, type: T) -> Bool {
    if !JWT<T>.verify(token, using: jwtVerifier) { return false }

    let result = try? JWT<T>(jwtString: token).validateClaims() == .success
    return result ?? false
  }

  func toUserID<T: TokenClaims>(_ request: RouterRequest, type: T) -> Int? {
    guard let header = request.headers["Authorization"],
      let token = header.components(separatedBy: " ").last else { return nil }

    return try? JWT<T>(jwtString: token).claims.sub
  }

  func toUserID<T: TokenClaims>(_ token: String, type: T) -> Int? {
    return try? JWT<T>(jwtString: token).claims.sub
  }
}
