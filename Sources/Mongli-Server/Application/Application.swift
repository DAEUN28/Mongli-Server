import Foundation

import Kitura
import KituraContracts
import SwiftJWT
import SwiftKueryMySQL
import SwiftKuery

public class App {

  // MARK: Database
  private static let poolOptions = ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 5)
  private static let connectionURL = URL(string: SecurityInformation.databaseURL)!
  private let pool = MySQLConnection.createPool(url: connectionURL, poolOptions: poolOptions)

  // MARK: JWT
  private static let jwtSigner = JWTSigner.rs256(privateKey: SecurityInformation.privateKey)
  private static let jwtVerifier = JWTVerifier.rs256(publicKey: SecurityInformation.publicKey)
  private let jwtEncoder = JWTEncoder(jwtSigner: jwtSigner)
  private let jwtDecoder = JWTDecoder(jwtVerifier: jwtVerifier)

  // MARK: Kitura
  private let router = Router()

  public init() {
    router.encoders[MediaType(type: .application, subType: "jwt")] = { return self.jwtEncoder }
    router.decoders[MediaType(type: .application, subType: "jwt")] = { return self.jwtDecoder }
  }

  public func run() {
    Kitura.addHTTPServer(onPort: 8080, with: router)
    Kitura.run()
  }
}
