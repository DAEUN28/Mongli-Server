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

  func createToken(_ id: Int, name: String, type: TokenType) -> String? {
    var jwt: JWT<TokenClaims>

    switch type {
    case .access:
      jwt = JWT(header: Header(),
                claims: TokenClaims(exp: Date(timeIntervalSinceNow: 3600), id: id, name: name))
    case .refresh:
      jwt = JWT(header: Header(),
                claims: TokenClaims(exp: Date(timeIntervalSinceNow: 1209600), id: id, name: name))
    }

    return try? jwt.sign(using: self.jwtSigner)
  }

  func isVaildate(_ token: String) -> Bool {
    if !JWT<TokenClaims>.verify(token, using: jwtVerifier) { return false }

    let result = try? JWT<TokenClaims>(jwtString: token, verifier: jwtVerifier).validateClaims() == .success
    return result ?? false
  }

  func toUserID(_ request: RouterRequest) -> Int? {
    guard let header = request.headers["Authorization"],
      let token = header.components(separatedBy: " ").last else { return nil }

    return try? JWT<TokenClaims>(jwtString: token).claims.id
  }

  func toUserName(_ token: String) -> String? {
    return try? JWT<TokenClaims>(jwtString: token).claims.name
  }

  func toUserID(_ token: String) -> Int? {
    return try? JWT<TokenClaims>(jwtString: token).claims.id
  }
}
