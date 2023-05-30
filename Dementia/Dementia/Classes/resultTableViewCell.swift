import UIKit

class resultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultData: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        resultView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
