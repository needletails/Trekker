//
//  URLSession+Extension.swift
//  Trekker
//
//  Created by NeedleTails App BrewHub on 1/8/25.
//
import Foundation

enum RequestType: String {
    case post = "POST"
    case get = "GET"
    case delete = "DELETE"
    case put = "PUT"
}

struct Response<T: Codable> {
    let data: T?
    let urlResponse: URLResponse
}

extension URLSession {
    enum Errors: Error {
        case httpBodyIsEmpty, responseError(String, String)
    }
    
    enum RequestType: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    func request<T: Codable>(
        url: URL,
        method: RequestType,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> Response<T> {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Set headers if provided
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        var (data, response): (Data, URLResponse)
        switch method {
        case .post, .put, .delete:
            (data, response) = try await self.upload(for: request, from: body ?? Data())
        case .get:
            (data, response) = try await self.data(for: request)
        }
        
        // Handle the response
        return try handleResponse(data: data, response: response)
    }
    
    private func handleResponse<T: Codable>(data: Data, response: URLResponse) throws -> Response<T> {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // Check for successful status codes (2xx)
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorData = data.isEmpty ? nil : String(data: data, encoding: .utf8)
            //TODO: Handle Better
            throw Errors.responseError("HTTPResponseStatus Code: \(httpResponse.statusCode)", "Response Data: \(errorData ?? "No response data")")
        }
        
        // Check if T conforms to Decodable
        let decodedResponse = try? JSONDecoder().decode(T.self, from: data)
        return Response(data: decodedResponse, urlResponse: response)
    }
}
