import Foundation

import Kitura
import KituraContracts

struct Dream: Codable {
  let id: Int?
  let date: String
  let category: Int
  let title: String
  let content: String
}

struct ID: Identifier {
  let id: Int

  var value: String
  init(value: String) throws {
    self.value = value
    if let id = Int(value) {
      self.id = id
    } else {
      throw RequestError.badRequest
    }
  }
}
