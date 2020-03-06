import Foundation

import SwiftKueryMySQL
import SwiftKuery

class UserTable: Table {
  let tableName = "User"
  let id = Column("id", String.self, primaryKey: true)
  let number = Column("number", Int32.self)
  let name = Column("name", String.self)
  let accessToken = Column("accessToken", String.self)
  let refreshToken = Column("refreshToken", String.self)
}

class DreamTable: Table {
  let tableName = "Dream"
  let id = Column("id", Int32.self, primaryKey: true)
  let uid = Column("uid", Int32.self)
  let date = Column("date", SQLDate.self)
  let category = Column("category", Int32.self)
  let title = Column("title", String.self)
  let content = Column("content", String.self)
}

