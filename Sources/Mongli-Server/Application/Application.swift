import Foundation

import Kitura
import KituraContracts
import SwiftKueryMySQL
import SwiftKuery

func initializeRoutes(app: App) {
  // post
  app.router.post("/auth", handler: app.signInHandler)
  app.router.post("/dream", handler: [app.tokenHandler, app.createDreamHandler])

  // get
  app.router.get("/auth/token", handler: [app.tokenHandler, app.renewalTokenHandler])
  app.router.get("/auth", handler: [app.tokenHandler, app.readUserAnalysisHandler])
  app.router.get("/dream/:id", handler: app.tokenHandler)
  app.router.get("/dream/:id", handler: app.readDreamHandler)
  app.router.get("/calendar/:month", handler: [app.tokenHandler, app.readMonthlyDreamsHandler])
  app.router.get("/dreams/:date", handler: [app.tokenHandler, app.readDailyDreamsHandler])
  app.router.get("/search", handler: [app.tokenHandler, app.searchDreamHandler])
  
  // put, patch
  app.router.patch("/auth", handler: [app.tokenHandler, app.renameHandler])
  app.router.put("/dream", handler: [app.tokenHandler, app.updateDreamHandler])

  // delete
  app.router.delete("/auth/token", handler: app.revokeTokenHandler)
  app.router.delete("/auth", handler: [app.tokenHandler, app.deleteUserHandler])
  app.router.delete("/dream/:id", handler: app.tokenHandler)
  app.router.delete("/dream/:id", handler: app.deleteDreamHandler)
  app.router.delete("/dream", handler: [app.tokenHandler, app.deleteDailyDreamsHandler])
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

  func tokenHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
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
