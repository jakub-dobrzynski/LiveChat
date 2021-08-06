import UIKit
import Firebase

class ChatViewController: UIViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages: [Message] = []
    
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        title = Constans.appName
        
        tableView.register(UINib(nibName: Constans.cellNibName, bundle: nil), forCellReuseIdentifier: Constans.cellIdentifier)
        
        loadMessages()
    }
    
    func loadMessages()
    {
        db.collection(Constans.FStore.collectionName).order(by: Constans.FStore.dateField).addSnapshotListener { (querSnapshot, error) in
            
            self.messages = []
            
            if let e = error
            {
                print("Issue retrieving data from Firebase \(e)")
            }
            else
            {
                if let snapshotDocument = querSnapshot?.documents
                {
                    for doc in snapshotDocument
                    {
                        let data = doc.data()
                        if let messageSender = data[Constans.FStore.senderField] as? String, let messageBody = data[Constans.FStore.bodyField] as? String
                       {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async
                            {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                       }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton)
    {
        if messageTextfield.text != ""
        {
            if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email
            {
                db.collection(Constans.FStore.collectionName).addDocument(data: [
                    Constans.FStore.senderField: messageSender,
                    Constans.FStore.bodyField: messageBody,
                    Constans.FStore.dateField: Date().timeIntervalSince1970
                ]){ error in
                    if let e = error
                    {
                        print("There was issue saving data into Firebase \(e)")
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            self.messageTextfield.text = ""
                        }
                    }
                }
            }
        }
        else{}
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem)
    {
        do
        {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        }
        catch let signOutError as NSError
        {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constans.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email
        {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        }
        else
        {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        return cell
    }
}


