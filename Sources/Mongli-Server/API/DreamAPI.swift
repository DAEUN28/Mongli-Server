import Foundation

import Kitura
import LoggerAPI
import SwiftJWT
import SwiftKueryMySQL

extension App {
  // MARK: CreateDreamHandler
  func createDreamHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last,
      let dream = try? request.read(as: Dream.self) else {
        response.status(.badRequest)
        return next()
    }

    guard let id = self.tokenManager.toUserID(accessToken) else {
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
  func readDreamHandler(id: ID, completion: @escaping (Dream?, RequestError?) -> Void) {
    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        return completion(nil, .internalServerError)
      }

      connection.execute(query: QueryManager.readDream(id.id).query()) { result in
        result.asRows { queryResult, error in
          if let error = error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
          }

          guard let queryResult = queryResult,
            let id = queryResult.first?["id"] as? Int32,
            let date = queryResult.first?["date"] as? String,
            let category = queryResult.first?["category"] as? Int32,
            let title = queryResult.first?["title"] as? String,
            let content = queryResult.first?["content"] as? String else {
              return completion(nil, .notFound)
          }

          let dream = Dream(id: Int(id), date: date, category: Int(category), title: title, content: content)
          return completion(dream, .ok)
        }
      }
    }
  }

  // MARK: UpdateDreamHandler
  func updateDreamHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let dream = try? request.read(as: Dream.self), let id = dream.id else {
      response.status(.badRequest)
      return next()
    }

    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.updateDream(dream, id: id).query()) { result in
        if let error = result.asError {
          Log.error(error.localizedDescription)
          response.status(.internalServerError)
          return next()
        }

        response.status(.noContent)
        return next()
      }
    }
  }

  // MARK: DeleteDreamHandler
  func deleteDreamHandler(id: ID, completion: @escaping (RequestError?) -> Void) {
    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        return completion(.internalServerError)
      }

      connection.execute(query: QueryManager.deleteDream(id.id).query()) { result in
        if let error = result.asError {
          Log.error(error.localizedDescription)
          return completion(.internalServerError)
        }

        if let value = result.asValue as? String, value.components(separatedBy: " ").first == "0" {
          return completion(.notFound)
        }

        return completion(.noContent)
      }
    }
  }
}

extension App {
  // MARK: ReadMonthlyDreamsHandler
  func readMonthlyDreamsHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last,
      let month = request.queryParameters["month"] else {
        response.status(.badRequest)
        return next()
    }

    guard let id = self.tokenManager.toUserID(accessToken) else {
      response.status(.internalServerError)
      return next()
    }

    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.readMonthlyDreams(month, id: id).query()) { result in
        result.asRows { queryResult, error in
          if let error = result.asError {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            return next()
          }

          guard let queryResult = queryResult else {
            response.status(.noContent)
            return next()
          }

          var result = [String: [Int]]()

          for dic in queryResult {
            guard let date = dic["date"] as? String, let category = dic["category"] as? Int32 else {
              response.status(.internalServerError)
              return next()
            }

            if result[date] == nil {
              result[date] = [Int(category)]
            } else {
              result[date]?.append(Int(category))
            }
          }

          response.status(.OK)
          response.send(result)
          return next()
        }
      }
    }
  }

  // MARK: ReadDailyDreamsHandler
  func readDailyDreamsHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last,
      let date = request.queryParameters["date"] else {
        response.status(.badRequest)
        return next()
    }

    guard let id = self.tokenManager.toUserID(accessToken) else {
      response.status(.internalServerError)
      return next()
    }

    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.readDailyDreams(date, id: id).query()) { result in
        result.asRows { queryResult, error in
          if let error = result.asError {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            return next()
          }

          guard let queryResult = queryResult else {
            response.status(.noContent)
            return next()
          }

          guard let result = SummaryDreams(queryResult) else {
            response.status(.internalServerError)
            return next()
          }

          response.status(.OK)
          response.send(result)
          return next()
        }
      }
    }
  }

  // MARK: DeleteDailyDreamsHandler
  func deleteDailyDreamsHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last,
      let date = request.queryParameters["date"] else {
        response.status(.badRequest)
        return next()
    }

    guard let id = self.tokenManager.toUserID(accessToken) else {
      response.status(.internalServerError)
      return next()
    }

    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.deleteDailyDreams(date, id: id).query()) { result in
        result.asRows { queryResult, error in
          if let error = result.asError {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            return next()
          }

          if let value = result.asValue as? String, value.components(separatedBy: " ").first == "0" {
            response.status(.notFound)
            return next()
          }

          response.status(.noContent)
          return next()
        }
      }
    }
  }

  // MARK: SearchDreamHandler
  func searchDreamHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let header = request.headers["Authorization"],
      let accessToken = header.components(separatedBy: " ").last,
      let condition = SearchCondition(request.queryParameters) else {
        response.status(.badRequest)
        return next()
    }

    guard let id = self.tokenManager.toUserID(accessToken) else {
      response.status(.internalServerError)
      return next()
    }

    self.pool.getConnection { connection, error in
      guard let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.readDreams(condition, id: id).query()) { result in
        result.asRows { queryResult, error in
          if let error = result.asError {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            return next()
          }

          guard let queryResult = queryResult else {
            response.status(.noContent)
            return next()
          }

          guard let result = SummaryDreams(queryResult) else {
            response.status(.internalServerError)
            return next()
          }

          response.status(.OK)
          response.send(result)
          return next()
        }
      }
    }
  }
}
