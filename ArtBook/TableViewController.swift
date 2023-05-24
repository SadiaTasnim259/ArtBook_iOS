//
//  TableViewController.swift
//  ArtBook
//
//  Created by Sadia on 8/5/23.
//

import UIKit
import CoreData

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var yearArray = [String]()
    //na bujha
    var selectedPainting = ""
    var selectedPantingId: UUID?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        getData()
    }
    
    //get data
    func getData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest) as! [NSManagedObject]
            if results.count > 0 {
                for result in results{
                    
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    
                    
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    
                    if let year = result.value(forKey: "year") as? String{
                        self.yearArray .append(year)
                    }
                }
                
                self.tableView.reloadData()
            }
            
        }catch{
            print("Fetch Error in GetData: \(error.localizedDescription)")
        }
    }
    
    
    //get data
    func getDataByObject(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Paintings>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results{
                
                if let name = result.name {
                    self.nameArray.append(name)
                }
                 
                if let id = result.id{
                    self.idArray.append(id)
                }
                
                if let year = result.year{
                    self.yearArray.append(year)
                }
            }
            
            self.tableView.reloadData()
        }catch{
            print("Fetch Error in GetDataByObject: \(error.localizedDescription)")
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        selectedPainting = ""
        selectedPantingId = nil
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        secondViewController.chosenPainting = selectedPainting
        secondViewController.chosenPaintingId = selectedPantingId
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
}
extension TableViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else{
            return UITableViewCell()
        }
        
        cell.artNameLabel.text = nameArray[indexPath.row]
        cell.yearLabel.text = yearArray[indexPath.row]
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                } catch {
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
        }
    }
}

extension TableViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedPainting = nameArray[indexPath.row]
        selectedPantingId = idArray[indexPath.row]
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        secondViewController.chosenPainting = selectedPainting
        secondViewController.chosenPaintingId = selectedPantingId
        
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
