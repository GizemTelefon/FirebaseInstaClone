//
//  FeedCelll.swift
//  FirebaseInstaClone
//
//  Created by Gizem Telefon on 9.01.2024.
//

import UIKit
import FirebaseFirestore

class FeedCelll: UITableViewCell {

    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var documentIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        let fireStoreDatabase = Firestore.firestore()
        if let likeCount = Int(likeLabel.text!) {
            let likeStore = ["likes" : likeCount + 1] as [String : Any] // Firebase string any istediği için böyle kaydettik.
            fireStoreDatabase.collection("Posts").document(documentIdLabel.text!).setData(likeStore, merge: true)
            // fireStoreDatabase.collection("Posts").document(documentIdLabel.text!): Likelabel'da yazanı int e çevirir.
            // setData: Güncellemek için yazdık. İçindeki merge'ü özellikle seçtik. merge: birleştir demek. Yani sadece like'ı güncelle demek diğerlerine dokunma demek aslında.
        }
        
    }
    
}
