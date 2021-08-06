import UIKit
import Firebase

class RegisterViewController: UIViewController
{

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton)
    {
       if let email = emailTextfield.text, let password = passwordTextfield.text
       {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error
                {
                    self.emailError.text = e.localizedDescription
                }
                else
                {
                    self.performSegue(withIdentifier: Constans.registerSegue, sender: self)
                }
            }
       }
    }
}
