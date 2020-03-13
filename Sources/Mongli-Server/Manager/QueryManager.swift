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
  case readMonthlyDreams(_ month: String, id: Int)
  case readDailyDreams(_ date: String, id: Int)
  case readDreams(_ condition: SearchCondition, id: Int)
  case readUserAnalysis(_ id: Int)
  case readUserInfo(_ id: Int)

  // update
  case updateRefreshToken(_ refreshToken: String, id: Int)
  case updateRefreshTokenToNULL(_ id: Int)
  case updateName(_ name: String, id: Int)
  case updateDream(_ dream: Dream, id: Int)

  // delete
  case deleteUser(_ id: Int)
  case deleteDream(_ id: Int)
  case deleteDailyDreams(_ date: String, id: Int)
}

extension QueryManager {
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

    case let .readMonthlyDreams(month, id):
      return Select([dreamTable.date, dreamTable.category], from: dreamTable)
        .where(dreamTable.date.like(month + "%") && dreamTable.userID == id)
        .order(by: [OrderBy.DESC(dreamTable.date), OrderBy.ASC(dreamTable.updateTime)])

    case let .readDailyDreams(date, id):
      return Select([dreamTable.id, dreamTable.category, dreamTable.title, dreamTable.content], from: dreamTable)
        .where(dreamTable.date.like(date) && dreamTable.userID == id)
        .order(by: OrderBy.ASC(dreamTable.updateTime))

    case let .readDreams(condition, id):
      var query = Select([dreamTable.id, dreamTable.date, dreamTable.category, dreamTable.title, dreamTable.content],
                         from: dreamTable)
        .limit(to: 10)
        .offset(condition.page * 10)

      var queryFilters = [Filter]()

      if condition.criteria == 0 {
        queryFilters.append(dreamTable.title.like("%" + condition.keyword! + "%"))
      } else if condition.criteria == 1 {
        queryFilters.append(dreamTable.content.like("%" + condition.keyword! + "%"))
      }

      if let category = condition.category {
        queryFilters.append(dreamTable.category == category)
      }

      if let period = condition.period?.components(separatedBy: "~"),
        let start = period.first, let end = period.last {
        queryFilters.append(dreamTable.date.between(start, and: end))
      }

      query = query.where(queryFilters.reduce(dreamTable.userID == id) { $0 && $1 })

      if condition.alignment == 0 {
        query = query.order(by: OrderBy.DESC(dreamTable.date))
      } else {
        query = query.order(by: OrderBy.ASC(dreamTable.date))
      }
      
      return query

    case let .readUserAnalysis(id):
      return Select([dreamTable.category, count(dreamTable.id).as("count")], from: dreamTable)
        .leftJoin(userTable)
        .on(dreamTable.userID == userTable.id)
        .group(by: dreamTable.category)
        .where(userTable.id == id)

    case let .readUserInfo(id):
      return Select([userTable.name, count(dreamTable.id).as("total")], from: dreamTable)
        .leftJoin(userTable)
        .on(dreamTable.userID == userTable.id)
        .where(userTable.id == id)

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

    case let .deleteDailyDreams(date, id):
      return Delete(from: dreamTable).where(dreamTable.date.like(date) && dreamTable.userID == id)
    }
  }
}
