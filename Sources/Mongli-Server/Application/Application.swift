import Foundation

import Kitura
import KituraContracts
import LoggerAPI
import SwiftKueryMySQL
import SwiftKuery

func initializeRoutes(app: App) {
  // post
  app.router.post("/api/auth", handler: app.signInHandler)
  app.router.post("/api/dream", handler: [app.tokenHandler, app.createDreamHandler])

  // get
  app.router.get("/api/auth/token", handler: [app.tokenHandler, app.renewalTokenHandler])
  app.router.get("/api/auth", handler: [app.tokenHandler, app.readAnalysisHandler])
  app.router.get("/api/dream/:id", handler: app.tokenHandler)
  app.router.get("/api/dream/:id", handler: app.readDreamHandler)
  app.router.get("/api/calendar/:month", handler: [app.tokenHandler, app.readMonthlyDreamsHandler])
  app.router.get("/api/dreams/:date", handler: [app.tokenHandler, app.readDailyDreamsHandler])
  app.router.get("/api/dreams", handler: [app.tokenHandler, app.searchDreamHandler])
  
  // put, patch
  app.router.patch("/api/auth", handler: [app.tokenHandler, app.renameHandler])
  app.router.put("/api/dream", handler: [app.tokenHandler, app.updateDreamHandler])

  // delete
  app.router.delete("/api/auth/token", handler: app.revokeTokenHandler)
  app.router.delete("/api/auth", handler: [app.tokenHandler, app.deleteUserHandler])
  app.router.delete("/api/dream/:id", handler: app.tokenHandler)
  app.router.delete("/api/dream/:id", handler: app.deleteDreamHandler)
  app.router.delete("/api/dreams/:date", handler: [app.tokenHandler, app.deleteDailyDreamsHandler])
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
    Kitura.addHTTPServer(onPort: 8080, with: router)
    Kitura.run()
  }

  func tokenHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last else {
        return try response.status(.badRequest).end()
    }

    if !self.tokenManager.isVaildate(accessToken) {
      let dispatchGroup = DispatchGroup()
      dispatchGroup.enter()
      self.pool.getConnection { [weak self] connection, error in
        guard let connection = connection,
          let id = self?.tokenManager.toUserID(accessToken) else {
          Log.error(error?.localizedDescription ?? "connectionError")
          response.status(.internalServerError)
          return dispatchGroup.leave()
        }

        let params = ["nil": nil] as [String: Any?]
        connection.execute(query: QueryManager.updateRefreshTokenToNULL(id).query(), parameters: params) { result in
          if let error = result.asError {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            return dispatchGroup.leave()
          }

          if let value = result.asValue as? String, value.components(separatedBy: " ").first == "0" {
            response.status(.notFound)
            return dispatchGroup.leave()
          }

          response.status(.unauthorized)
          return dispatchGroup.leave()
        }
      }

      dispatchGroup.wait()
      switch response.statusCode {
      case .internalServerError, .notFound, .unauthorized: try response.end()
      default: break
      }
    }

    return next()
  }
}
