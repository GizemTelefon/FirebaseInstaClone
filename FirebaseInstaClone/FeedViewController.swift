//
//  FeedViewController.swift
//  FirebaseInstaClone
//
//  Created by Gizem Telefon on 8.01.2024.
//

import UIKit
import FirebaseFirestore
import SDWebImage


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var userEmailArray = [String]()
    var userCommentArray = [String]()
    var likeArray = [Int]()
    var userImageArray = [String]()
    var documentIdArray = [String]() // Likelerı alabilmek için ekledik
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getDataFromFirestore()
                
    }
    
        func getDataFromFirestore() {
            let fireStoreDatabase = Firestore.firestore()
            var settings = fireStoreDatabase.settings // Firestore ayarlarını değiştirmek için kullandığımız bir yöntem. Tarih için yaptık bunu.
            settings = FirestoreSettings()
            fireStoreDatabase.settings = settings
            
            self.userImageArray.removeAll(keepingCapacity: false)   // Bunları paylaşımları birden fazla kez eklemesin diye yaptık.
            self.userEmailArray.removeAll(keepingCapacity: false)
            self.userCommentArray.removeAll(keepingCapacity: false)
            self.likeArray.removeAll(keepingCapacity: false)
            self.documentIdArray.removeAll(keepingCapacity: false)
            
            fireStoreDatabase.collection("Posts").order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
                // order(by): Tarihe göre dizmesini istiyoruz.
                // snapshot: Çektiğimiz koleksiyondaki dökümanları bize verilir.
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    if snapshot?.isEmpty != true && snapshot != nil  { // snapshot boş değilse
                        for document in snapshot!.documents { // snapshot!.documents: Posts altındaki bütün dökümanların dizisini verir.
                            let documentID = document.documentID // Buradan sonra uygulamayı çalıştırınca Feed ekranındaki dökümanların ID'lerini Firebase sitesinde POSTS'ların içerisinde görebilirsin. Aynı ID'yi veriyor sana.
                            self.documentIdArray.append(documentID) // Like'ları alabilmek için ekledik.
                            print (documentID)
                            
                            if let postedBy = document.get("postedBy") as? String {
                                self.userEmailArray.append(postedBy)
                            }
                            if let postComment = document.get("postComment") as? String {
                                self.userCommentArray.append(postComment)
                            }
                            if let likes = document.get("likes") as? Int {
                                self.likeArray.append(likes)
                            }
                            if let imageUrl = document.get("imageUrl") as? String {
                                self.userImageArray.append(imageUrl)
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCelll
        cell.userEmailLabel.text = userEmailArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        cell.commentLabel.text = userCommentArray[indexPath.row]
        cell.userImageView.sd_setImage(with: URL(string: self.userImageArray[indexPath.row]))
        cell.documentIdLabel.text = documentIdArray[indexPath.row]
        return cell
    }
    // Görüntüleri çekmek için internetten bir kütüphaneden yararlanacağız. Bunu "ios swift async image load into imageview" yazarak aratıp bulabiliriz.
    // Hoca en iyi çalışan SDWebImage dediği için githup üzerinden bunu yazarak aratıp o kütüphaneye kolayca ulaştık.
}
