import Foundation

import Kitura
import KituraContracts
import LoggerAPI
import SwiftJWT
import SwiftKueryMySQL
import SwiftKuery
import AuthenticationServices


extension App {
  func signInHandler(auth: Auth, completion: @escaping (Token?, RequestError?) -> Void) {
    if let name = auth.name {
      self.pool.getConnection { [weak self] connection, error in
        guard let self = self, let connection = connection else {
          Log.error(error?.localizedDescription ?? "connectionError")
          return completion(nil, .internalServerError)
        }

        connection.execute(query: QueryManager.createUser(auth.uid, name: name).query()) { result in
          if let error = result.asError {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
          }
          
          connection.execute(query: QueryManager.readUserID(auth.uid).query()) { result in
            guard let resultSet = result.asResultSet else {
              Log.error(result.asError?.localizedDescription ?? "readUserIDQueryError")
              return completion(nil, .internalServerError)
            }

            resultSet.forEach(operation: { row, error in
              guard let id = row?.first as? Int32 else { return }

              if let error = error {
                Log.error(error.localizedDescription)
                return completion(nil, .internalServerError)
              }

              guard let accessToken = self.tokenManager.createToken(AccessTokenClaim(sub: Int(id))),
                let refreshToken = self.tokenManager.createToken(RefreshTokenClaim(sub: Int(id))) else {
                  Log.error("createTokenError")
                  return completion(nil, .internalServerError)
              }

              self.pool.getConnection { connection, error in
                guard let connection = connection else {
                  Log.error(error?.localizedDescription ?? "connectionError")
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
            })
          }
        }
      }
    }

    self.pool.getConnection { [weak self] connection, error in
      guard let self = self, let connection = connection else {
        Log.error(error?.localizedDescription ?? "connectionError")
        return completion(nil, .internalServerError)
      }

      connection.execute(query: QueryManager.readRefreshToken(auth.uid).query()) { result in
        guard let resultSet = result.asResultSet else {
          Log.error(result.asError?.localizedDescription ?? "readRefreshTokenError")
          return completion(nil, .internalServerError)
        }

        resultSet.forEach(operation: { row, error in
          if let _ = row?.first as? String {
            return completion(nil, .conflict)
          }

          if let error = error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
          }
        })

        connection.execute(query: QueryManager.readUserID(auth.uid).query()) { result in
          guard let resultSet = result.asResultSet else {
            Log.error(result.asError?.localizedDescription ?? "readUserIDQueryError")
            return completion(nil, .internalServerError)
          }

          resultSet.forEach(operation: { row, error in
            guard let id = row?.first as? Int32 else { return }

            if let error = error {
              Log.error(error.localizedDescription)
              return completion(nil, .internalServerError)
            }

            guard let accessToken = self.tokenManager.createToken(AccessTokenClaim(sub: Int(id))),
              let refreshToken = self.tokenManager.createToken(RefreshTokenClaim(sub: Int(id))) else {
                Log.error("createTokenError")
                return completion(nil, .internalServerError)
            }

            self.pool.getConnection { connection, error in
              guard let connection = connection else {
                Log.error(error?.localizedDescription ?? "connectionError")
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
          })
        }
      }
    }

    return completion(nil, .notFound)
  }
}
