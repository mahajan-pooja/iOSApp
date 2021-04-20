import Foundation
import UIKit

class APIClient {
    static func getMainCategory(url: URL, completion: @escaping (Result<[MainCategory], NetworkError>) -> Void) {
        
        APIService.get(request: url) { result in
            switch result {
            case .success(let data):
                do {
                    let mainCategory = try JSONDecoder().decode([MainCategory].self, from: data)
                    completion(.success(mainCategory))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure:
                completion(.failure(.invalidData))
            }
        }
    }
    
    static func getCountryCategory(url: URL, completion: @escaping (Result<[CountryCategory], NetworkError>) -> Void) {
        
        APIService.get(request: url) { result in
            switch result {
            case .success(let data):
                do {
                    let countryCategory = try JSONDecoder().decode([CountryCategory].self, from: data)
                    completion(.success(countryCategory))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure:
                completion(.failure(.invalidData))
            }
        }
    }
    
    static func getHomeCategory(url: URL, completion: @escaping (Result<HomeCategory, NetworkError>) -> Void) {
        
        APIService.get(request: url) { result in
            switch result {
            case .success(let data):
                do {
                    let homeCategory = try JSONDecoder().decode(HomeCategory.self, from: data)
                    completion(.success(homeCategory))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure:
                completion(.failure(.invalidData))
            }
        }
    }
    
    static func downloadImage(url: String, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let url = URL(string: url) else {
            return completion(.failure(NetworkError.invalidData))
        }
        
        APIService.get(request: url) { result in
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                completion(.success(image))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
