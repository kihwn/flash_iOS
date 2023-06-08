import UIKit

class homeViewController: UIViewController {
    @IBOutlet weak var testBTN: UIButton!
    @IBOutlet weak var recent_resultBTN: UIButton!
    @IBOutlet weak var resultBTN: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func buttonInit(){
        testBTN.layer.cornerRadius = 12
        recent_resultBTN.layer.cornerRadius = 12
        resultBTN.layer.cornerRadius = 12
    }
    
    @IBAction func testBTNTap(_ sender: Any) {
        let testSB = UIStoryboard(name: "Test", bundle: nil)
        let testVC = testSB.instantiateViewController(withIdentifier:"test")
        self.navigationController?.pushViewController(testVC, animated: true)
    }
    
    @IBAction func recentResultBTNTap(_ sender: Any) {
        let resultSB = UIStoryboard(name: "Result", bundle: nil)
        let recentVC = resultSB.instantiateViewController(withIdentifier:"recent")
        self.navigationController?.pushViewController(recentVC, animated: true)
    }
    
    @IBAction func resultBTNTap(_ sender: Any) {
        let resultSB = UIStoryboard(name: "Result", bundle: nil)
        let resultVC = resultSB.instantiateViewController(withIdentifier:"result")
        self.navigationController?.pushViewController(resultVC, animated: true)
    }
}

