
import Foundation
import Alamofire


public typealias Parameters = [String: AnyObject]
public typealias Headers = HTTPHeaders
public typealias JSONObject = [String: AnyObject]
public typealias JSONArray = [AnyObject]


public protocol Requestable: class {
  /// Request data from an url resource
  /// - Parameter url: Endpoint resource
  /// - Parameter verb: HTTP Method 'GET', 'POST', 'DELETE', 'UPDATE', 'PATCH'
  /// - Parameter parameters: Body or query parameters are optionals
  /// - Parameter headers: Headers are optionals
  /// - Parameter encoding: URL encoding type
  /// - Parameter completion: Response after the request is complete
  func requestData(to url: String,
                   verb: HTTPMethod,
                   parameters: Parameters?,
                   headers: Headers?,
                   encoding: URLEncoding,
                   completion: @escaping (Result<Data, Error>) -> ())
  
  func requestObject(to url: String,
                     verb: HTTPMethod,
                     parameters: Parameters?,
                     headers: Headers?,
                     encoding: URLEncoding,
                     completion: @escaping (Result<JSONObject, Error>) -> ())
  
  func requestArray(to url: String,
                    verb: HTTPMethod,
                    parameters: Parameters?,
                    headers: Headers?,
                    encoding: URLEncoding,
                    completion: @escaping (Result<JSONArray, Error>) -> ())
}

// MARK: - Request Data
extension Requestable {
  public func requestData(to url: String,
                   verb: HTTPMethod,
                   parameters: Parameters?,
                   headers: Headers?,
                   encoding: URLEncoding,
                   completion: @escaping (Result<Data, Error>) -> ()) {
    
    guard let urlConvertible = URL(string: url) else {
      completion(.failure(ErrorManager.invalidURL))
      return
    }
    
    let _ = AF.request(urlConvertible,
                       method: verb,
                       parameters: parameters,
                       encoding: encoding,
                       headers: headers)
      .validate()
      .responseData { (response) in
        switch response.result {
        case .success(let data):
          completion(.success(data))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }
}

// MARK: - Request JSON Object
extension Requestable {
  public func requestObject(to url: String,
                     verb: HTTPMethod,
                     parameters: Parameters?,
                     headers: Headers?,
                     encoding: URLEncoding,
                     completion: @escaping (Result<JSONObject, Error>) -> ()) {
    
    requestData(to: url, verb: verb, parameters: parameters, headers: headers, encoding: encoding) { (result) in
      switch result {
        
      case .success(let data):
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? JSONObject else {
          completion(.failure(ErrorManager.invalidJSONObject))
          return
        }
        completion(.success(jsonObject))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}

// MARK: - Request JSON Array
extension Requestable {
  public func requestArray(to url: String,
                    verb: HTTPMethod,
                    parameters: Parameters?,
                    headers: Headers?,
                    encoding: URLEncoding,
                    completion: @escaping (Result<JSONArray, Error>) -> ()) {
    
    requestData(to: url,
                verb: verb,
                parameters: parameters,
                headers: headers,
                encoding: encoding) { (result) in
                  
                  switch result {
                  case .success(let data):
                    guard
                      let jsonArray = try? JSONSerialization
                        .jsonObject(
                          with: data,
                          options: .mutableContainers
                        ) as? JSONArray
                      else {
                        completion(.failure(ErrorManager.invalidJSONArray))
                        return
                    }
                    
                    completion(.success(jsonArray))
                    
                  case .failure(let error):
                    completion(.failure(error))
                  }
    }
    
  }
}
