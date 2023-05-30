import UIKit

class resultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var resultTV: UITableView!
    var resultData:ResultRP = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultTV.delegate = self
        resultTV.dataSource = self
        getResult()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "result") as? resultTableViewCell else {return UITableViewCell()}
        cell.resultData.text = resultData[indexPath.row].date
        cell.resultLabel.text = resultData[indexPath.row].testResult

        if resultData[indexPath.row].testResult == "위험"{
            cell.resultView.backgroundColor = .red
        }
        if resultData[indexPath.row].testResult == "주의"{
            cell.resultView.backgroundColor = .orange
        }
        if resultData[indexPath.row].testResult == "양호"{
            cell.resultView.backgroundColor = .green
        }
        
        return cell
    }
    
    
    func getResult(){
        
        let url = URL(string: "http://13.209.75.213:8080/user/")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        if let storedCookies = HTTPCookieStorage.shared.cookies(for: url!) {
            // 쿠키를 요청에 추가
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: storedCookies)
            request.allHTTPHeaderFields = cookieHeaders
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let output = try? JSONDecoder().decode(ResultRP.self, from: data!) else {
                print("ERR")
                return
            }
            print(output)
            self.resultData = output
            DispatchQueue.main.async {
                self.resultTV.reloadData()
            }
        }
        
        task.resume()
    }
}

// MARK: - ResultRPElement
struct ResultRPElement: Codable {
    let date, testResult: String

    enum CodingKeys: String, CodingKey {
        case date
        case testResult = "TestResult"
    }
}

typealias ResultRP = [ResultRPElement]
