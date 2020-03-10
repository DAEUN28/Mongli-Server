import Foundation

import Kitura
import KituraContracts
import SwiftKueryMySQL
import SwiftKuery

func initializeRoutes(app: App) {
  app.router.post("/auth", handler: app.signInHandler)
  app.router.get("/auth/token", handler: app.renewalTokenHandler)
}

public class App {

  // MARK: Database
  let pool: ConnectionPool

  // MARK: Kitura
  let router = Router()
  let tokenManager = TokenManager()

  public init() {
    let poolOptions = ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 5)
    let connectionURL = URL(string: SecurityInformation.databaseURL)!
    pool = MySQLConnection.createPool(url: connectionURL, poolOptions: poolOptions)
    
    router.encoders[MediaType(type: .application, subType: "jwt")]
      = { return self.tokenManager.jwtEncoder }
    router.decoders[MediaType(type: .application, subType: "jwt")]
      = { return self.tokenManager.jwtDecoder }

    initializeRoutes(app: self)
  }

  public func run() {
    Kitura.addHTTPServer(onPort: 2525, with: router)
    Kitura.run()
  }
}
