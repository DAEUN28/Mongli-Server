import Foundation

import Kitura
import KituraContracts
import SwiftKueryMySQL
import SwiftKuery

enum QueryManager {
  // create
  case createUser(_ uid: String, _ name: String)
  case createDream(_ dream: Dream, id: Int)

  // read
  case readUserIDWithUID(_ uid: String)
  case readUserIDWithUserID(_ id: Int)
  case readRefreshToken(_ uid: String)
  case readDream(_ id: Int)

  // update
  case updateRefreshToken(_ refreshToken: String, id: Int)
  case updateRefreshTokenToNULL(_ id: Int)
  case updateName(_ name: String, id: Int)
  case updateDream(_ dream: Dream, id: Int)

  // delete
  case deleteUser(_ id: Int)

  func query() -> Query {
    let userTable = UserTable()
    let dreamTable = DreamTable()
    
    switch self {
    case let .createUser(uid, name):
      return Insert(into: userTable,
                    columns: [userTable.uid, userTable.name],
                    values: [uid, name])

    case let .createDream(dream, id):
      return Insert(into: dreamTable,
                    columns: [dreamTable.userID, dreamTable.date, dreamTable.category, dreamTable.title, dreamTable.content],
                    values: [id, dream.date, dream.category, dream.title, dream.content])

    case let .readUserIDWithUID(uid):
      return Select(userTable.id, from: userTable).where(userTable.uid.like(uid))

    case let .readUserIDWithUserID(id):
      return Select(userTable.id, from: userTable)
        .where(userTable.id == id)

    case let .readRefreshToken(uid):
      return Select(userTable.refreshToken, from: userTable)
        .where(userTable.uid.like(uid))

    case let .readDream(id):
      return Select([dreamTable.id, dreamTable.date, dreamTable.category, dreamTable.title, dreamTable.content],
                    from: dreamTable)
        .where(dreamTable.id == id)
      
    case let .updateRefreshToken(refreshToken, id):
      return Update(userTable, set: [(userTable.refreshToken, refreshToken)])
        .where(userTable.id == id)

    case let .updateRefreshTokenToNULL(id):
      return Update(userTable, set: [(userTable.refreshToken, Parameter("nil"))])
        .where(userTable.id == id)

    case let .updateName(name, id):
      return Update(userTable, set: [(userTable.name, name)])
        .where(userTable.id == id)

    case let .updateDream(dream, id):
      return Update(dreamTable, set: [(dreamTable.date, dream.date),
                                      (dreamTable.category, dream.category),
                                      (dreamTable.title, dream.title),
                                      (dreamTable.content, dream.content)])
        .where(dreamTable.id == id)

    case let .deleteUser(id):
      return Delete(from: userTable).where(userTable.id == id)
    }
  }
}
