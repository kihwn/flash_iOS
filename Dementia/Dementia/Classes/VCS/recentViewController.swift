import UIKit

class recentViewController: UIViewController {
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getData(completion: {(data, error) in
            let alertController = UIAlertController(title: "오류", message: "다시 시도해주세요.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
                alertController.dismiss(animated: true, completion: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            alertController.addAction(okAction)
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            
            guard let output = try? JSONDecoder().decode(RecentRP.self, from: data!) else {
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            print(output)
            
            DispatchQueue.main.async {
                self.time.text = "시간: " + output.date
                self.overviewLabel.text = output.result
                if output.result == "위험"{
                    self.resultView.backgroundColor = .red
                    self.info.text = "정확한 진료를 위해서는 병원에 내원하여 검사를 받아주세요.\n가까운 보건소, 치매지원센터, 정신건강의학과나 신경과에서 진단을 받을 수 있습니다.\n\n위험 : 당신의 상태는 치매 위험 상태입니다.\n\n치매가 의심되는 상태입니다. 이 시기는 무엇보다도 병원에서 약을 처방받아 드시는 것이 중요합니다. 정확한 진료와 판단을 위해 가까운 보건소, 치매지원센터, 정신건강의학과, 신경과를 내원해 심층 검사 받는 것을 추천드립니다.\n초기 치매는 최근 대화를 반복적으로 잊거나 길눈이 어두워지는 등 일상생활에 문제가 생깁니다. 이 시기부터는 가족들의 도움이 일부 필요합니다. 가족이 어르신을 돌보는데 도움이 필요하시면 국민건강 보험 공단 1577-1000으로 신청하세요."
                }
                if output.result == "주의"{
                    self.resultView.backgroundColor = .orange
                    self.info.text = "정확한 진료를 위해서는 병원에 내원하여 검사를 받아주세요.\n가까운 보건소, 치매지원센터, 정신건강의학과나 신경과에서 진단을 받을 수 있습니다.\n\n주의 : 당신의 상태는 치매 주의 상태입니다.\n\n경도인지장애가 의심됩니다. 경도인지장애 단계에서는 기억력 저하가 있기 하지만 본인 스스로 충분히 생활할 수 있는 단계로 치매는 아니지만 치매 위험이 존재하는 단계입니다. 해당 단계에서는 관리에 따라 현재 상태를 그대로 유지할 수도 있고, 치매로 진행될 수도 있는 중요한 단계입니다. 다음 지시사항을 이행해보세요.\n고혈압과 당뇨를 주의하고 금연을 해주시고, 과식과 편식을 피해주세요.\n또한 운동을 지속적으로 하는 것도 도움이 됩니다. 주 3회 이상 하루에 빨리 걷기를 45분에서 한 시간 정도 하는 것이 좋습니다. 또한 스트레스를 받지 않는 환경을 조성해주세요. 일상생활이 기쁘지 않으면 우울증이 발생할 수 있고 우울증은 치매를 불러올 수 있습니다."
                }
                if output.result == "양호"{
                    self.resultView.backgroundColor = .green
                    self.info.text = "정확한 진료를 위해서는 병원에 내원하여 검사를 받아주세요.\n가까운 보건소, 치매지원센터, 정신건강의학과나 신경과에서 진단을 받을 수 있습니다.\n\n안전 : 당신의 상태는 치매 안전 상태입니다.\n\n건강하신 상태입니다. 빠른 치매 진단과 예방을 위해 주기적으로 검사를 진행해주세요."
                }
            }
            
        })
    }
    
    func getData(completion: @escaping (Data?, Error?) -> Void){
        let url = URL(string: "http://54.180.75.134:8080/dementia/result")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        if let storedCookies = HTTPCookieStorage.shared.cookies(for: url!) {
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: storedCookies)
            request.allHTTPHeaderFields = cookieHeaders
        }
        
        URLSession.shared.dataTask(with: request){(data, _, error) in
            if let error = error{
                completion(nil, error)
                return
            }
            completion(data, nil)
        }.resume()
    }
}
// MARK: - ResultRP
struct RecentRP: Codable {
    let date, result: String
}
