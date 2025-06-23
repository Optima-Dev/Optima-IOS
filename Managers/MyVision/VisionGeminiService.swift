import Foundation
import UIKit

class VisionGeminiService {
    private let apiKey = "AIzaSyA2ZS-vr3MVEr_ioWAmzBa-8lX9EbuT7r8"
    private let session = URLSession.shared

    func analyzeImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(
                domain: "ImageConversion",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image."])))
            return
        }

        let base64Image = imageData.base64EncodedString()
        let requestURL = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=\(apiKey)")!

        // Prompt to avoid generic intro sentence
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "text": "Analyze this image and give a detailed description only. Do not include any introductory phrases."
                        ]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(
                    domain: "NoData",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No data returned from API."])))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    completion(.success(text))
                } else {
                    completion(.failure(NSError(
                        domain: "ParsingError",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to parse API response."])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
