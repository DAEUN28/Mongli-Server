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

struct SummaryDreams: Codable {
  let total: Int?
  let dreams: [SummaryDream]

  init?(_ total: Int?, _ queryResult: [[String : Any?]]) {
    var result = [SummaryDream]()

    for dic in queryResult {
      guard let id = dic["id"] as? NSNumber,
        let category = dic["category"] as? NSNumber,
        let title = dic["title"] as? String,
        let content = dic["content"] as? String else { return nil }

      let summary = content.components(separatedBy: [".", "\n"]).first
        ?? String(content[content.startIndex..<content.index(content.startIndex, offsetBy: 28)])

      result.append(SummaryDream(id: Int(truncating: id),
                                 date: dic["date"] as? String,
                                 category: Int(truncating: category),
                                 title: title,
                                 summary: summary))
    }

    self.total = total
    self.dreams = result
    return
  }
}

struct SummaryDream: Codable {
  let id: Int
  let date: String?
  let category: Int
  let title: String
  let summary: String

  init(id: Int, date: String?, category: Int, title: String, summary: String) {
    self.id = id
    self.date = date
    self.category = category
    self.title = title
    self.summary = summary
  }
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

struct SearchCondition {
  let page: Int
  let criteria: Int
  let sort: Int
  let category: Int?
  let period: String?
  let keyword: String?

  init?(_ queryParameters: [String: String]) {
    guard let pageString = queryParameters["page"],
      let criteriaString = queryParameters["criteria"],
      let sortString = queryParameters["sort"],
      let page = Int(pageString),
      let criteria = Int(criteriaString),
      let sort = Int(sortString) else { return nil }

    if criteria != 2 && queryParameters["keyword"]?.isEmpty == true {
      return nil
    }

    self.page = page
    self.criteria = criteria
    self.sort = sort
    self.period = queryParameters["period"]
    self.keyword = queryParameters["keyword"]
    
    if let categoryString = queryParameters["category"] {
      self.category = Int(categoryString)
    } else {
      self.category = nil
    }

    return
  }
}
