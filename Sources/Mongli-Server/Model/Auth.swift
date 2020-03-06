import Foundation

struct Auth: Codable {
  let uid: String
  let name: String?
}

struct Token: Codable {
  let accessToken: String
  let refreshToken: String
}
