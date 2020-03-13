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
  case readUserID(_ uid: String)
  case readRefreshTokenWithUserID(_ id: Int)
  case readRefreshToken(_ uid: String)
  case readDream(_ id: Int)
  case readMonthlyDream(_ month: String, id: Int)

  // update
  case updateRefreshToken(_ refreshToken: String, id: Int)
  case updateRefreshTokenToNULL(_ id: Int)
  case updateName(_ name: String, id: Int)
  case updateDream(_ dream: Dream, id: Int)

  // delete
  case deleteUser(_ id: Int)
  case deleteDream(_ id: Int)

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
                    columns: [dreamTable.userID,
                              dreamTable.date,
                              dreamTable.category,
                              dreamTable.title,
                              dreamTable.content,
                              dreamTable.updateTime],
                    values: [id, dream.date, dream.category, dream.title, dream.content, Date()])

    case let .readUserID(uid):
      return Select(userTable.id, from: userTable).where(userTable.uid.like(uid))

    case let .readRefreshTokenWithUserID(id):
      return Select(userTable.refreshToken, from: userTable)
        .where(userTable.id == id)

    case let .readRefreshToken(uid):
      return Select(userTable.refreshToken, from: userTable)
        .where(userTable.uid.like(uid))

    case let .readDream(id):
      return Select([dreamTable.id, dreamTable.date, dreamTable.category, dreamTable.title, dreamTable.content],
                    from: dreamTable)
        .where(dreamTable.id == id)

    case let .readMonthlyDream(month, id):
      return Select([dreamTable.date, dreamTable.category], from: dreamTable)
        .where(dreamTable.date.like(month + "%") && dreamTable.userID == id)
        .order(by: [OrderBy.DESC(dreamTable.date), OrderBy.ASC(dreamTable.updateTime)])
      
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
                                      (dreamTable.content, dream.content),
                                      (dreamTable.updateTime, Date())])
        .where(dreamTable.id == id)

    case let .deleteUser(id):
      return Delete(from: userTable).where(userTable.id == id)

    case let .deleteDream(id):
      return Delete(from: dreamTable).where(dreamTable.id == id)
    }
  }
}
