import UIKit

class modifyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textData[0].text.count + textData[1].text.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "modifyCell") as? modifyTableViewCell else{
            return UITableViewCell()
            
        }
        
        if indexPath.row % 2 == 1{
            cell.nameLabel.text = textData[1].name
            cell.textView.text = textData[1].text[indexPath.row / 2]
        } else {
            cell.nameLabel.text = textData[0].name
            cell.textView.text = textData[0].text[indexPath.row / 2]
        }
        
        self.view.layoutIfNeeded()
        let size = CGSize(width: cell.textView.frame.width, height: .infinity)
        let estimatedSize = cell.textView.sizeThatFits(size)
        cell.heightConstraints.constant = estimatedSize.height
        
        return cell
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTV: UITableView!
    var textData: TestRP = []
    var modifyRQData: modifyRQ = modifyRQ(radio: "", textA: [], textB: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textTV.dataSource = self
        textTV.delegate = self
    }
    
    @objc func keyboardAppear(_ sender : Any){
        UIView.animate(withDuration: 1){
            self.bottomConstraint.constant = 400
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDisappear(_ sender : Any){
        UIView.animate(withDuration: 1) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func BTNA(){
        makeData()
        modifyRQData.radio = "A"
        sendData()
    }
    
    @IBAction func BTNB(){
        makeData()
        modifyRQData.radio = "B"
        sendData()
    }
    
    func makeData(){
        modifyRQData = modifyRQ(radio: "", textA: [], textB: [])
        if(textData[0].text.count + textData[1].text.count  > 0){
            for i in 0...textData[0].text.count + textData[1].text.count - 1{
                let cell = textTV.cellForRow(at: IndexPath(row: i, section: 0)) as! modifyTableViewCell
                if i % 2 == 1{
                    modifyRQData.textB.append(cell.textView.text)
                } else {
                    modifyRQData.textA.append(cell.textView.text)
                }
            }
        }
    }
    
    func sendData(){
        print(modifyRQData)
        let url = URL(string: "http://54.180.75.134:8080/dementia/modified")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uploadData = try? JSONEncoder().encode(modifyRQData)
        if let storedCookies = HTTPCookieStorage.shared.cookies(for: url!) {
            // 쿠키를 요청에 추가
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: storedCookies)
            request.allHTTPHeaderFields = cookieHeaders
        }
        
        
        URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let output = try? JSONDecoder().decode(Bool.self, from: data!) {
                let alertController = UIAlertController(title: "성공", message: "업로드 성공", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
                    alertController.dismiss(animated: true, completion: {
                        if let navigationController = self.navigationController {
                            let viewControllers = navigationController.viewControllers
                            
                            if viewControllers.count >= 2 {
                                let targetViewController = viewControllers[viewControllers.count - 3]
                                navigationController.popToViewController(targetViewController, animated: true)
                            } else if viewControllers.count == 1 {
                                navigationController.popViewController(animated: true)
                            }
                        }
                    })
                }
                alertController.addAction(okAction)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            let alertController = UIAlertController(title: "오류", message: "다시 시도해주세요.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
                alertController.dismiss(animated: true, completion: {
                    if let navigationController = self.navigationController {
                        let viewControllers = navigationController.viewControllers
                        
                        if viewControllers.count >= 2 {
                            let targetViewController = viewControllers[viewControllers.count - 3]
                            navigationController.popToViewController(targetViewController, animated: true)
                        } else if viewControllers.count == 1 {
                            navigationController.popViewController(animated: true)
                        }
                    }
                })
            }
            alertController.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion:nil)
            }
            
            
        }.resume()
    }
}

struct modifyRQ: Encodable {
    var radio: String
    var textA, textB: [String]
}
