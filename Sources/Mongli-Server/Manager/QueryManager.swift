import Foundation

import Kitura
import KituraContracts
import SwiftKueryMySQL
import SwiftKuery

enum QueryManager {
  case createUser(_ uid: String, _ name: String)
  case readUserIDWithUID(_ uid: String)
  case readUserIDWithUserID(_ id: Int)
  case readRefreshToken(_ uid: String)
  case updateRefreshToken(_ refreshToken: String, id: Int)
  case updateRefreshTokenToNULL(_ id: Int)
  case updateName(_ name: String, id: Int)
  case deleteUser(_ id: Int)

  func query() -> Query {
    let userTable = UserTable()
    let dreamTable = DreamTable()
    
    switch self {
    case let .createUser(uid, name):
      return Insert(into: userTable,
                    columns: [userTable.uid, userTable.name],
                    values: [uid, name])

    case let .readUserIDWithUID(uid):
      return Select(userTable.id, from: userTable).where(userTable.uid.like(uid))

    case let .readUserIDWithUserID(id):
      return Select(userTable.id, from: userTable)
        .where(userTable.id == id)

    case let .readRefreshToken(uid):
      return Select(userTable.refreshToken, from: userTable)
        .where(userTable.uid.like(uid))
      
    case let .updateRefreshToken(refreshToken, id):
      return Update(userTable, set: [(userTable.refreshToken, refreshToken)])
        .where(userTable.id == id)

    case let .updateRefreshTokenToNULL(id):
      return Update(userTable, set: [(userTable.refreshToken, Parameter("nil"))])
        .where(userTable.id == id)

    case let .updateName(name, id):
      return Update(userTable, set: [(userTable.name, name)])
        .where(userTable.id == id)

    case let .deleteUser(id):
      return Delete(from: userTable).where(userTable.id == id)
    }
  }
}
