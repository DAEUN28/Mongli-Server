import Foundation

import Kitura
import KituraContracts
import SwiftKueryMySQL
import SwiftKuery

public class App {

  private static let poolOptions = ConnectionPoolOptions(initialCapacity: 1, maxCapacity: 5)
  private static let connectionURL = URL(string: "mysql://root:1128@127.0.0.1:5252/Mongli")!

  private let pool = MySQLConnection.createPool(url: connectionURL, poolOptions: poolOptions)
  
  private let router = Router()

  public init() {

  }

  public func run() {
    Kitura.addHTTPServer(onPort: 8080, with: router)
    Kitura.run()
  }
}
