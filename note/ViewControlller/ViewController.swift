//
//  ViewController.swift
//  note
//
//  Created by MacBook Pro on 07/05/2024.
//

import UIKit
import CoreData

final class ViewController: UIViewController {

    var result: [NSFetchRequestResult] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
//        deleteAllCoreData()
//        creatData()
        retrieveData()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveData()
        tableView.reloadData()
    }
    
    private func setupUI() {
        
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: .main), forCellReuseIdentifier: "TableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func creatData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let note = NSEntityDescription.entity(forEntityName: "Note", in: managedContext) else
        {return}
        
        for i in 1 ... 5 {
            let note = NSManagedObject(entity: note, insertInto: managedContext)
            let timeStamp = Date().timeIntervalSince1970
            note.setValue("\(timeStamp)", forKeyPath: "id")
            note.setValue("\(i)adsflkhalkdfh;ladsfkahds;fkh;akhdf;as", forKeyPath: "detail")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError{
            debugPrint("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func retrieveData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        do {
            result = try managedContext.fetch(fetchRequest)
        } catch {
            debugPrint("Failed")
        }
    }
    
    private func deleteAllCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch {
            debugPrint("Failed")
        }
    }
    
    
}
//MARK: button
extension ViewController {
    @IBAction func tapAddButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController else {
            return
        }
        vc.typeOfView = .newNote
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDelegate {
//MARK: select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = result[indexPath.row] as? NSManagedObject, let id = note.value(forKey: "id") else
        {return}
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as? NoteDetailViewController else {
            return
        }
        vc.typeOfView = .noteDetail
        vc.id = id as! String
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            guard let note = self.result[indexPath.row] as? NSManagedObject, let id = note.value(forKey: "id") else
            {return}
            self.deleteItem(id: id as! String)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        deleteAction.backgroundColor = .red
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
//MARK: delete
    private func deleteItem(id: String) {
        debugPrint("delete Item")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let note = try managedContext.fetch(fetchRequest)
            guard let noteToDelete = note.first as? NSManagedObject else
            {return}
            
            managedContext.delete(noteToDelete)
            
            try managedContext.save()
        } catch {
            debugPrint("Failed")
        }
        self.retrieveData()
        self.tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        guard let note = result[indexPath.row] as? NSManagedObject, let detail = note.value(forKey: "detail") else
        {return cell}
        cell.render(detail: detail as! String)
        return cell
    }
    
    
}

extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let noteDetailVC = segue.destination as? NoteDetailViewController {
            if let id = sender {
                noteDetailVC.id = id as! String
            }
        }
    }
}
