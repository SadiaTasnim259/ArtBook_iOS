//
//  ViewController.swift
//  ArtBook
//
//  Created by Sadia on 8/5/23.
//

import UIKit
import CoreData

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artNameField: UITextField!
    @IBOutlet weak var publishYearField: UITextField!
    @IBOutlet weak var artistYearField: UITextField!
    //na bujha
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //na bujha
        if chosenPainting != "" {
            // Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            artNameField.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String{
                           artistYearField.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? String{
                            publishYearField.text = year
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch{
                print("error")
            }
            
        }else{
            artNameField.text = ""
            publishYearField.text = ""
            artistYearField.text = ""
        }
        
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        view.addGestureRecognizer(gestureRecognizer)
    }

//    @objc func hideKeyboard(){
//        view.endEditing(true)
//    }
    
    
    @IBAction func selectImagePressed(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                
                self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.dismiss(animated: true)
        }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        //store data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //attributes
        
        newPainting.setValue(artNameField.text, forKey: "name")
        newPainting.setValue(publishYearField.text, forKey: "year")
        newPainting.setValue(artistYearField.text, forKey: "artist")
        newPainting.setValue(UUID(), forKey: "id")
       
        let imageData = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(imageData, forKey: "image")
        
        do{
            try context.save()
            print("Save")
        }catch{
            print("Error")
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
}

