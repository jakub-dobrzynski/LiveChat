import UIKit

class WelcomeViewController: UIViewController
{

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel.text = ""
        var chIndex = 0
        let titleText = Constans.appName
        for letter in titleText
        {
            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(chIndex), repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            chIndex += 1
        }
    }
    
}
