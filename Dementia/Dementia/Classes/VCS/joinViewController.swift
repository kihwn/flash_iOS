import UIKit

class joinViewController: UIViewController {
    
    @IBOutlet weak var verifyBTN: UIButton!
    @IBOutlet weak var joinBTN: UIButton!
    @IBOutlet weak var nicknameTF: UITextField!
    @IBOutlet weak var idTF: UITextField!
    @IBOutlet weak var pwTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonInit()
    }
    
    func buttonInit(){
        verifyBTN.layer.cornerRadius = 5
        joinBTN.layer.cornerRadius = 12
    }
    
    @IBAction func joinBTNTap(){
        tryJoin()
    }
    
    func tryJoin(){
        let alertController = UIAlertController(title: "회원가입 실패", message: "회원가입에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(okAction)
        
        
        let url = URL(string: "http://54.180.75.134:8080/user/signup")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let formData = [
            "nickname": nicknameTF.text ?? "",
            "user_id":  idTF.text ?? "",
            "password": pwTF.text ?? ""
        ]
        var bodyData = Data()
        
        // Append form data to body
        for (key, value) in formData {
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            bodyData.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = bodyData
         
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let output = try? JSONDecoder().decode(JoinRP.self, from: data!) {
                print(output.status)
                if output.status == 1 {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            }
            print("err")
            
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        task.resume()
    }
}


// MARK: - JoinRP
struct JoinRP: Codable {
    let userID: Int
    let uid, upw, name: String
    let status: Int
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case uid, upw, name, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
