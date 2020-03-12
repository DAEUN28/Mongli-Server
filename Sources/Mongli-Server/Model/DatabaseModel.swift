import Foundation

import SwiftKueryMySQL
import SwiftKuery

class UserTable: Table {
  let tableName = "User"
  let id = Column("id", primaryKey: true)
  let uid = Column("uid")
  let name = Column("name")
  let refreshToken = Column("refreshToken", notNull: false)
}

class DreamTable: Table {
  let tableName = "Dream"
  let id = Column("id", primaryKey: true)
  let userID = Column("userID")
  let date = Column("date")
  let category = Column("category")
  let title = Column("title")
  let content = Column("content")
  let updateTime = Column("updateTime")
}

