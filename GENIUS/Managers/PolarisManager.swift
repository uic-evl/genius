import Foundation

struct PolarisCommands {
    var inputs: [String]
    var outputs: [String]
    var directory: String
}

func sendPostRequest(command: [String], directory: String, completion: @escaping (PolarisCommands) -> Void ) {
    guard let url = URL(string: "http://" + Login().getIP() + ":5000/polaris")
    else {
        print("Invalid URL")
        completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = [
        "user": Login().getUser(),
        "password": Login().getPass(),
        "command": command,
        "directory": directory
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    } catch {
        print("Failed to serialize JSON: \(error)")
        completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
            return
        }
        
        guard let data = data else {
            print("No data")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let output = json["output"] as? [String], let directory = json["directory"] as? String{
                print("JSON Response: \(json)")
                print("Directory: \(directory)")
                completion(PolarisCommands(inputs: command, outputs: output, directory: directory))
            } else {
                completion(PolarisCommands(inputs: ["error2"], outputs: ["error2"], directory: "error2"))
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            completion(PolarisCommands(inputs: ["error"], outputs: ["error"], directory: ""))
        }
    }
    
    task.resume()
}


func codeRequest(command: String, completion: @escaping (String) -> Void ) {
    guard let url = URL(string: "http://" + Login().getIP() + ":5000/video") else {  //127.0.0.1:5000
        print("Invalid URL")
        completion("error")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = [
        "user": Login().getUser(),
        "password": Login().getPass(),
        "command": command,
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    } catch {
        print("Failed to serialize JSON: \(error)")
        completion("error")
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion("error")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Invalid response")
            completion("error")
            return
        }
        
        guard let data = data else {
            print("No data")
            completion("error")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let output = json["output"] as? [String], let directory = json["directory"] as? String{
                print("JSON Response: \(json)")
                print("Directory: \(directory)")
                completion("true")
            } else {
                completion("error2")
            }
        } catch {
            print("Failed to decode JSON: \(error)")
            completion("error")
        }
    }
    
    task.resume()
}
