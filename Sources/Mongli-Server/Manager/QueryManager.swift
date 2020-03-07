import Foundation

import Kitura
import KituraContracts
import SwiftKueryMySQL
import SwiftKuery

enum QueryManager {
  case createUser(_ uid: String, name: String)
  case readUserID(_ uid: String)
  case updateRefreshToken(_ refreshToken: String, id: Int)

  func query() -> Query {
    let userTable = UserTable()
    let dreamTable = DreamTable()
    
    switch self {
    case let .createUser(uid, name):
      return Insert(into: userTable,
                    columns: [userTable.uid, userTable.name],
                    values: [uid, name])

    case let .readUserID(uid):
      return Select(userTable.id, from: userTable)
        .where(userTable.uid == uid)

    case let .updateRefreshToken(refreshToken, id):
      return Update(userTable, set: [(userTable.refreshToken, refreshToken)])
        .where(userTable.id == id)
    }
  }
}
