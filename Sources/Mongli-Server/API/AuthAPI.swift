import Foundation

import Kitura
import KituraContracts
import LoggerAPI
import SwiftJWT
import SwiftKueryMySQL
import SwiftKuery
import AuthenticationServices


extension App {

  // MARK: SignInHandler
  func signInHandler(auth: Auth, completion: @escaping (Token?, RequestError?) -> Void) {
    let dispatchGroup = DispatchGroup()

    /// signUp
    if let name = auth.name {
      self.pool.getConnection { [weak self] connection, error in
        guard let self = self, let connection = connection else {
          Log.error(error?.localizedDescription ?? "connectionError")
          return completion(nil, .internalServerError)
        }

        dispatchGroup.enter()
        connection.execute(query: QueryManager.createUser(auth.uid, name: name).query()) { result in
          if let error = result.asError {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
          }
          dispatchGroup.leave()
        }

        dispatchGroup.wait()
        connection.execute(query: QueryManager.readUserIDWithUID(auth.uid).query()) { result in
          result.asRows { queryResult, error in
            if let error = error {
              Log.error(error.localizedDescription)
              return completion(nil, .internalServerError)
            }

            guard let id = queryResult?.first?["id"] as? Int32,
              let accessToken = self.tokenManager.createToken(AccessTokenClaim(sub: Int(id))),
              let refreshToken = self.tokenManager.createToken(RefreshTokenClaim(sub: Int(id))) else {
                Log.error("createTokenError")
                return completion(nil, .internalServerError)
            }

            connection.execute(query: QueryManager.updateRefreshToken(refreshToken, id: Int(id)).query()) { result in
              if let error = result.asError {
                Log.error(error.localizedDescription)
                return completion(nil, .internalServerError)
              }

              let response = Token(accessToken: accessToken, refreshToken: refreshToken)
              return completion(response, .created)
            }
          }
        }
      }
    }

    /// signIn
    self.pool.getConnection { [weak self] connection, error in
      guard let self = self, let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        return completion(nil, .internalServerError)
      }

      dispatchGroup.enter()
      connection.execute(query: QueryManager.readRefreshToken(auth.uid).query()) { result in
        result.asRows { queryResult, error in
          if let error = error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
          }
          guard let queryResult = queryResult else { return completion(nil, .notFound) }
          if let _ = queryResult.first?["refreshToken"] as? String { return completion(nil, .conflict) }
          dispatchGroup.leave()
        }
      }

      dispatchGroup.wait()
      connection.execute(query: QueryManager.readUserIDWithUID(auth.uid).query()) { result in
        result.asRows { queryResult, error in
          if let error = error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
          }

          guard let id = queryResult?.first?["id"] as? Int32,
            let accessToken = self.tokenManager.createToken(AccessTokenClaim(sub: Int(id))),
            let refreshToken = self.tokenManager.createToken(RefreshTokenClaim(sub: Int(id))) else {
              Log.error("createTokenError")
              return completion(nil, .internalServerError)
          }

          connection.execute(query: QueryManager.updateRefreshToken(refreshToken, id: Int(id)).query()) { result in
            if let error = result.asError {
              Log.error(error.localizedDescription)
              return completion(nil, .internalServerError)
            }

            let response = Token(accessToken: accessToken, refreshToken: refreshToken)
            return completion(response, .ok)
          }
        }
      }
    }
  }

  // MARK: RenewalTokenHandler
  func renewalTokenHandler(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) {
    guard let header = request.headers["Authorization"],
      let refreshToken = header.components(separatedBy: " ").last else {
        response.status(.badRequest)
        return next()
    }

    if !self.tokenManager.isVerified(refreshToken, type: RefreshTokenClaim(sub: 0)) {
      response.status(.unauthorized)
      return next()
    }

    guard let id = self.tokenManager.toUserID(refreshToken, type: RefreshTokenClaim(sub: 0)) else {
      response.status(.internalServerError)
      return next()
    }

    self.pool.getConnection { [weak self] connection, error in
      guard let self = self, let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        response.status(.internalServerError)
        return next()
      }

      connection.execute(query: QueryManager.readUserIDWithUserID(id).query()) { result in
        result.asRows { queryResult, error in
          if let error = error {
            Log.error(error.localizedDescription)
            response.status(.internalServerError)
            return next()
          }

          guard let queryResult = queryResult else {
            response.status(.notFound)
            return next()
          }

          guard let id = queryResult.first?["id"] as? Int32,
            let accessToken = self.tokenManager.createToken(AccessTokenClaim(sub: Int(id))) else {
            Log.error("createTokenError")
            response.status(.internalServerError)
            return next()
          }

          response.status(.created)
          response.send(AccessToken(accessToken: accessToken))
          return next()
        }
      }
    }
  }
}
