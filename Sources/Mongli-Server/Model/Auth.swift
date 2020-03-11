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
