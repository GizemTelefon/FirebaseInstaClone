//
//  UploadViewController.swift
//  FirebaseInstaClone
//
//  Created by Gizem Telefon on 8.01.2024.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth


class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    
    //var chosenPainting = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true // fotoğrafa tıklanabilir yaptık
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        //  if chosenPainting != "" {
        //   let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // }
    }
    
    @objc func chooseImage() {
        let picker = UIImagePickerController() // Kullanıcının kütüphanesi erişmek için picker kullanıyoruz.
        picker.delegate = self // Gerekli methodları çağırmak için yapıyoruz bunu. Hata almamak için  UIImagePickerControllerDelegate, UINavigationControllerDelegate eklemek gerekiyor burada.
        picker.sourceType = .photoLibrary // Bu datayı kütüphaneden alsın dedik
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController (_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    { // Kullanıcı chooseImage ile fotoğraf seçtikten sonra ne olacak fonksiyonu.
        imageView?.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func makeAlert(tittleInput: String, messageInput: String) {
        let alert = UIAlertController (title: tittleInput , message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonClicked(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReferance = storage.reference() // Hangi klasörle çalışacağımızı, nereye kaydedeceğimizi belirtiyoruz.
        let mediaFolder = storageReferance.child("media") // child: bir alt klasör demek. İstediğin kadar child diyerek yeni bir alt klasör ekleyebilirsin.
        
        if let data = imageView.image!.jpegData(compressionQuality: 0.5) { // Bu seçilen fotoğrafı ne kadar sıkıştırayım diyor
            
            let uuid = UUID().uuidString // Her kullandığında bir öncekinden farklı bir değer almak için. Yani her kaydettiğim görseli farklı isimle kaydetsin diye.
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (metadata, error) in // Gerçekten kaydedebildik mi onu görmek için
                if error != nil {
                    self.makeAlert(tittleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                } else {
                    imageReference.downloadURL { (url, error) in
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString // url'yi al string'e çevirdik
                            
                            // DATABASE
                            
                            let firestoreDatabase = Firestore.firestore() //FireStore kütüphanesini çağırdık
                            var firestoreReference : DocumentReference? = nil // FireStore database'ini yazmak, okumak için oluşturduğumuz referans.
                            
                            let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email as Any, "postComment" : self.commentTextField.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0 ] as [String : Any]
                            // FieldValue.serverTimestamp(): Kullanıcının o anki zamanını alıp veriyor.
                            
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { (error) in
                                if error != nil {
                                    self.makeAlert(tittleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                                } else {
                                    self.imageView.image = UIImage(named: "select.png") // Fotoğraf yükledikten sonra tekrar yükleme ekranı açılsın diye ekledik.
                                    self.commentTextField.text = ""
                                    self.tabBarController?.selectedIndex = 0 // 0. index'e götür demek o da Feed ekranı oluyor. 1 = Upload 2 = Settings
                                }
                            })
                            
                            
                            
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    
    
}
