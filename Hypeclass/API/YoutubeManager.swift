//
//  YoutubeManager.swift
//  Hypeclass
//
//  Created by GOngTAE on 2022/08/04.
//

import Foundation

class YoutubeManager {
    static let shared = YoutubeManager()
    private let youtubeAppKey = Secret.youtubeAppKey
    
    private init() { }
    
    typealias NetworkCompletion = (Result<[Item], NetworkError>) -> Void
    
    
    func fetchYoutubeData(channelID: String ,completion: @escaping NetworkCompletion) {
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(channelID)&maxResults=5&order=date&key="
        let urlStringWithKey = "\(urlString)\(youtubeAppKey)"
        performRequest(with: urlStringWithKey) { result in
            completion(result)
        }
    }
    
    private func performRequest(with urlString: String, completion: @escaping NetworkCompletion) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                print(error!)
                completion(.failure(.networkingError))
                return
            }
            guard let safeData = data else {
                completion(.failure(.dataError))
                return
            }
            
            print("\(safeData.debugDescription)입니다")
            print("\(response.debugDescription)")
            print("\(response?.description)")
            if let youtubeData = self.parseJSON(safeData) {
                print("Parse 실행")
                completion(.success(youtubeData))
            } else {
                print("Parse 실패")
                completion(.failure(.parseError))
            }
        }
        task.resume()
    }
    
    private func parseJSON(_ youtubeData: Data) -> [Item]? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let youtubeData = try decoder.decode(YoutubeModelAPI.self, from: youtubeData)
            return youtubeData.items
        } catch {
            print("ERROR!")
            print(error.localizedDescription)
            print(error.localizedDescription.description)
            print(String(describing: error))
            return nil
        }
    }
}

enum NetworkError: Error {
    case networkingError
    case dataError
    case parseError
}

struct YoutubeModelAPI: Codable {
    let kind: String?
    let etag: String?
    let nextPageToken: String?
    let regionCode: String?
    let pageInfo: PageInfo?
    let items: [Item]?
}

struct Item: Codable {
    let kind: String?
    let etag: String?
    let id: ID
    let snippet: Snippet
}

struct ID: Codable {
    let kind: String?
    let videoID: String?

    enum CodingKeys: String, CodingKey {
        case kind
        case videoID = "videoId"
    }
}

struct Snippet: Codable {
    let publishedAt: Date?
    let channelID: String?
    let title: String?
    let snippetDescription: String?
    let thumbnails: Thumbnails
    let channelTitle, liveBroadcastContent: String?
    let publishTime: Date?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelID = "channelId"
        case title
        case snippetDescription = "description"
        case thumbnails, channelTitle, liveBroadcastContent, publishTime
    }
}

struct Thumbnails: Codable {
    let thumbnailsDefault: Default
    let medium: Default
    let high: Default

    enum CodingKeys: String, CodingKey {
        case thumbnailsDefault = "default"
        case medium, high
    }
}

struct Default: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct PageInfo: Codable {
    let totalResults: Int
    let resultsPerPage: Int
}
