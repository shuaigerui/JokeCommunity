//
//  JS_NetworkTool.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import Foundation
import SVProgressHUD

let urlPath = "https://api.fiveukmedia.xyz/le/afd/"

enum JS_NetworkError: Error {
    case invalidURL
    case emptyResponse
    case httpStatus(code: Int, data: Data?)
    case underlying(Error)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid request URL."
        case .emptyResponse:
            return "Empty response data."
        case .httpStatus(let code, _):
            return "Request failed with status code \(code)."
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

final class JS_NetworkTool {

    static let shared = JS_NetworkTool()

    private let defaultParameters: [String: String] = [
        "five": "66781AB9-7605-4AF8-9163-68D689792A93",
        "six": "1779788860268",
        "nine": "4450c8fb84d0cb7d9191921af247eceb942e63c33a65d7ee60a6cd80fc194442"
    ]

    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        session = URLSession(configuration: configuration)
    }

    /// POST 请求，自动合并默认参数；`isShow` 为 true 时展示/关闭 SVProgressHUD
    @discardableResult
    func post(
        parameters: [String: String] = [:],
        isShow: Bool = true,
        completion: @escaping (Result<Data, JS_NetworkError>) -> Void
    ) -> URLSessionDataTask? {
        guard let url = URL(string: urlPath) else {
            dismissHUDIfNeeded(isShow)
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return nil
        }

        showHUDIfNeeded(isShow)

        var merged = defaultParameters
        parameters.forEach { merged[$0.key] = $0.value }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = formEncodedBody(from: merged)

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.handleResponse(
                data: data,
                response: response,
                error: error,
                isShow: isShow,
                completion: completion
            )
        }
        task.resume()
        return task
    }

    /// POST 请求并解析 JSON
    @discardableResult
    func post<T: Decodable>(
        parameters: [String: String] = [:],
        isShow: Bool = true,
        completion: @escaping (Result<T, JS_NetworkError>) -> Void
    ) -> URLSessionDataTask? {
        post(parameters: parameters, isShow: isShow) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.underlying(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        isShow: Bool,
        completion: @escaping (Result<Data, JS_NetworkError>) -> Void
    ) {
        if let error {
            finish(isShow: isShow) {
                completion(.failure(.underlying(error)))
            }
            return
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            finish(isShow: isShow) {
                completion(.failure(.httpStatus(code: httpResponse.statusCode, data: data)))
            }
            return
        }

        guard let data else {
            finish(isShow: isShow) {
                completion(.failure(.emptyResponse))
            }
            return
        }

        finish(isShow: isShow) {
            completion(.success(data))
        }
    }

    private func formEncodedBody(from parameters: [String: String]) -> Data? {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&+=?")

        let query = parameters
            .map { key, value -> String in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            .joined(separator: "&")

        return query.data(using: .utf8)
    }

    private func showHUDIfNeeded(_ isShow: Bool) {
        guard isShow else { return }
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }

    private func dismissHUDIfNeeded(_ isShow: Bool) {
        guard isShow else { return }
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }

    private func finish(isShow: Bool, _ block: @escaping () -> Void) {
        guard isShow else {
            DispatchQueue.main.async(execute: block)
            return
        }
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            block()
        }
    }
}
