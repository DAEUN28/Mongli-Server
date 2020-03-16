import Foundation

struct Auth: Codable {
  let uid: String
  let name: String?
}

struct Token: Codable {
  let accessToken: String
  let refreshToken: String
}

struct AccessToken: Codable {
  let accessToken: String
}

struct Name: Codable {
  let name: String
}

struct UserAnalysis: Codable {
  var total: Int = 0
  var red: Int = 0
  var orange: Int = 0
  var yellow: Int = 0
  var green: Int = 0
  var teal: Int = 0
  var blue: Int = 0
  var indigo: Int = 0
  var purple: Int = 0

  mutating func insert(_ category: Int, count: Int) -> Bool {
    self.total += count
    
    switch category {
    case 0: self.red = count
    case 1: self.orange = count
    case 2: self.yellow = count
    case 3: self.green = count
    case 4: self.teal = count
    case 5: self.blue = count
    case 6: self.indigo = count
    case 7: self.purple = count
    default: return false
    }
    return true
  }
}
