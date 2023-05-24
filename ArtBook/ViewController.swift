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
    @IBOutlet weak var saveButton: UIButton!
    
    var forUpdate = false
    
    //na bujha
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //na bujha
        if chosenPainting != "" {
            
            forUpdate = true
            //saveButton.isHidden = true
            saveButton.setTitle("Update", for: .normal)
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
            forUpdate = false
            
            saveButton.isHidden = false
            saveButton.isEnabled = false
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
        saveButton.isEnabled = true
            self.dismiss(animated: true)
        }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        if forUpdate{
            updatePainting()
        }else{
            savePainting()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func updatePainting() {
        //store data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Assuming you have the "id" of the item you want to update stored in a variable called "itemId"

        // Fetch the existing item
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        guard let chosenPaintingId else { return  }
        
        fetchRequest.predicate = NSPredicate(format: "id == %@", chosenPaintingId.uuidString)

        do {
            let fetchResults = try context.fetch(fetchRequest)
            if let existingPainting = fetchResults.first as? NSManagedObject {
                // Update the attributes of the existing item
                existingPainting.setValue(artNameField.text, forKey: "name")
                existingPainting.setValue(publishYearField.text, forKey: "year")
                existingPainting.setValue(artistYearField.text, forKey: "artist")
                // Note: You may choose not to update the "id" attribute since it's typically a unique identifier.

                let imageData = imageView.image!.jpegData(compressionQuality: 0.5)
                existingPainting.setValue(imageData, forKey: "image")
                
                // Save the changes to the context
                try context.save()
                print("Update")
            }
        } catch {
            print("Error fetching or updating the item: \(error)")
        }

    }
    
    func savePainting(){
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
    }
}

