import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var firstConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondConstraint: NSLayoutConstraint!
    @IBOutlet weak var IDTF: UITextField!
    @IBOutlet weak var PWTF: UITextField!
    @IBOutlet weak var showPWBTN: UIButton!
    @IBOutlet weak var loginBTN: UIButton!
    @IBOutlet weak var joinBTN: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonInit()
        tfInit()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear_Login(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear_Login(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboard()
    }
    
    @IBAction func showPWTap(){
        PWTF.isSecureTextEntry = !PWTF.isSecureTextEntry
    }
    
    @IBAction func loginBTNTap(){
        tryLogin()
    }
    
    @IBAction func joinBTNTap(){
        let joinSB = UIStoryboard(name: "Join", bundle: nil)
        let joinVC = joinSB.instantiateViewController(withIdentifier: "join")
        self.present(joinVC, animated: true)
    }
    
    func buttonInit(){
        loginBTN.layer.cornerRadius = 5
        joinBTN.layer.cornerRadius = 5
        showPWBTN.alpha = 0
    }
    
    func tfInit(){
        PWTF.addTarget(self, action: #selector(showPWBTNenable), for: .editingChanged)
    }
    
    @objc func showPWBTNenable(){
        if(PWTF.text != ""){
            showPWBTN.alpha = 1
        }else{
            showPWBTN.alpha = 0
        }
    }
    
    @objc func keyboardAppear_Login(_ sender : Any){
        UIView.animate(withDuration: 1){
            self.firstConstraint.constant = 20
            self.secondConstraint.constant = 20
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDisappear_Login(_ sender : Any){
        UIView.animate(withDuration: 1) {
            self.firstConstraint.constant = 100
            self.secondConstraint.constant = 40
            self.view.layoutIfNeeded()
        }
    }
    
    func tryLogin(){
        let alertController = UIAlertController(title: "로그인 실패", message: "로그인에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(okAction)
        
        
        let url = URL(string: "http://13.209.75.213:8080/user/login")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let formData = [
            "uid": IDTF.text ?? "",
            "upw": PWTF.text ?? "",
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
            if let output = try? JSONDecoder().decode(Bool.self, from: data!) {
                if output {
//                    if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
//                            let cookies: [HTTPCookie] = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
//                            Common.cookies = cookies
//                        }
//
                    if let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                           // 쿠키 저장하기
                           let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: response!.url!)
                           HTTPCookieStorage.shared.setCookies(cookies, for: response!.url!, mainDocumentURL: nil)
                       }
                    DispatchQueue.main.async {
                        let homeSB = UIStoryboard(name: "Home", bundle: nil)
                        let homeVC = homeSB.instantiateViewController(withIdentifier:"home")
                        self.navigationController?.pushViewController(homeVC, animated: true)
                    }
                    
                    return
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

// MARK: - LoginRQ
struct LoginRQ: Codable {
    let uid, upw: String
}


