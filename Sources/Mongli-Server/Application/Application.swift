import Foundation

import Kitura
import KituraContracts
import SwiftKueryMySQL
import SwiftKuery

func initializeRoutes(app: App) {
  // post
  app.router.post("/auth", handler: app.signInHandler)
  app.router.post("/dream", handler: app.accessTokenHandler)
  app.router.post("/dream", handler: app.createDreamHandler)

  // get
  app.router.get("/auth/token", handler: app.refreshTokenHandler)
  app.router.get("/auth/token", handler: app.renewalTokenHandler)
  app.router.get("/dream/:id", handler: app.accessTokenHandler)
  app.router.get("/dream/:id", handler: app.readDreamHandler)
  
  // put, patch
  app.router.patch("/auth", handler: app.accessTokenHandler)
  app.router.patch("/auth", handler: app.renameHandler)
  app.router.put("/dream", handler: app.accessTokenHandler)
  app.router.put("/dream", handler: app.updateDreamHandler)

  // delete
  app.router.delete("/auth/token", handler: app.revokeTokenHandler)
  app.router.delete("/auth", handler: app.accessTokenHandler)
  app.router.delete("/auth", handler: app.deleteUserHandler)
  app.router.delete("/dream/:id", handler: app.accessTokenHandler)
  app.router.delete("/dream/:id", handler: app.deleteDreamHandler)
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

  func accessTokenHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last else {
        return try response.status(.badRequest).end()
    }

    if !self.tokenManager.isVaildate(accessToken) {
      return try response.status(.unauthorized).end()
    }

    return next()
  }

  func refreshTokenHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last else {
        return try response.status(.badRequest).end()
    }

    if !self.tokenManager.isVaildate(accessToken) {
      return try response.status(.unauthorized).end()
    }
    
    return next()
  }
}
