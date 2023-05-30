
import UIKit

class modifyTableViewCell: UITableViewCell, UITextViewDelegate {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.isScrollEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
