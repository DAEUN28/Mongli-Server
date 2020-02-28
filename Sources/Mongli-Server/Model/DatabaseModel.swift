import Foundation

import SwiftKueryMySQL
import SwiftKuery

class UserTable: Table {
  let tableName = "User"
  let id = Column("id", Int32.self, primaryKey: true)
  let name = Column("name", String.self)
  let accessToken = Column("name", String.self)
  let refreshToken = Column("name", String.self)
}

class DreamTable: Table {
  let tableName = "Dream"
  let id = Column("id", Int32.self, primaryKey: true)
  let uid = Column("uid", Int32.self)
  let date = Column("date", SQLDate.self)
  let category = Column("name", Int32.self)
  let title = Column("name", String.self)
  let content = Column("name", String.self)
}

