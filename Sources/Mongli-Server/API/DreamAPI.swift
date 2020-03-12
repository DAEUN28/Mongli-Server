import Foundation

import Kitura
import LoggerAPI
import SwiftJWT
import SwiftKueryMySQL

extension App {
  // MARK: CreateDreamHandler
  func createDreamHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let header = request.headers["Authorization"],
      let dream = try? request.read(as: Dream.self),
      let accessToken = header.components(separatedBy: " ").last else {
        response.status(.badRequest)
        return next()
    }

    guard let id = self.tokenManager.toUserID(accessToken, type: AccessTokenClaim(sub: 0)) else {
      response.status(.internalServerError)
      return next()
    }

    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.createDream(dream, id: id).query()) { result in
        if let error = result.asError {
          Log.error(error.localizedDescription)
          response.status(.internalServerError)
          return next()
        }

        response.status(.created)
        return next()
      }
    }
  }

  // MARK: ReadDreamHandler
  func readDreamHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let params = request.parameters["id"], let id = Int(params) else {
      response.status(.badRequest)
      return next()
    }

    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.readDream(id).query()) { result in
        result.asRows { queryResult, error in
          if let error = error {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            return next()
          }

          guard let queryResult = queryResult,
            let id = queryResult.first?["id"] as? Int32,
            let date = queryResult.first?["date"] as? String,
            let category = queryResult.first?["category"] as? Int32,
            let title = queryResult.first?["title"] as? String,
            let content = queryResult.first?["content"] as? String else {
            response.status(.notFound)
            return next()
          }

          response.status(.OK)
            .send(Dream(id: Int(id), date: date, category: Int(category), title: title, content: content))
          return next()
        }
      }
    }
  }
}
