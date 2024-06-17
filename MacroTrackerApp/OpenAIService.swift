

import Foundation

enum HTTPMethod: String {
    case post  = "POST"
    case get = "GET"
}

class OpenAIService{
    
    static let shared = OpenAIService()
    
    private init() {}
    
    private func generateURLRequest(httpsMethod: HTTPMethod, message: String) throws -> URLRequest {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        
        //Method
        urlRequest.httpMethod = httpsMethod.rawValue
        
        //Header
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(Secrets.apiKey)", forHTTPHeaderField: "Authorization")
        
        //Body
        let systemMessage = GPTMessage(role: "system", content: "you are a macronutrient expert .")
        let userMessage = GPTMessage(role: "user", content: message)
        
        let food = GPTFunctionProperty(type: "string", description: "The Food Iteam e.g Pizza")
        let fats = GPTFunctionProperty(type: "integer", description: "The amount of fats in grams in the given food item")
        let carbs = GPTFunctionProperty(type: "integer", description: "The amount of carbs in grams in the given food item")
        let protein = GPTFunctionProperty(type: "integer", description: "The amount of protein in grams in the given food item")
        let params : [ String : GPTFunctionProperty] = [
            "food": food,
            "fats": fats,
            "carbs": carbs,
            "protein": protein
        ]
        
        let functionParams = GPTFunctionParam(type: "object", properties: params, required: ["food", "fats", "carbs", "protein"])
        let function = GPTFunction(name: "get_macronutrients", description: "Get the macronutrient for the given food. ", parameters: functionParams)
        
        let payload = GPTChatPayload(model: "gpt-3.5-turbo", messages: [systemMessage, userMessage], functions: [function])
        let jsonData = try JSONEncoder().encode(payload)
        
        urlRequest.httpBody = jsonData
        
        return urlRequest
        
    }
    
    func sendPromptToChatGPT(message: String) async throws {
        let urlRequest = try generateURLRequest(httpsMethod: .post, message: message)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        
        print(String(data: data, encoding: .utf8)!)
    }
}

struct GPTChatPayload: Encodable {
    let model : String
    let messages: [GPTMessage]
    let functions: [GPTFunction]
}

struct GPTMessage : Encodable {
    let role : String
    let content : String
}

struct GPTFunction : Encodable {
    let name : String
    let description : String
    let parameters : GPTFunctionParam
}

struct GPTFunctionParam : Encodable {
    let type : String
    let properties : [String : GPTFunctionProperty]?
    let required : [String]?
}

struct GPTFunctionProperty: Encodable {
    let type: String
    let description: String
}
