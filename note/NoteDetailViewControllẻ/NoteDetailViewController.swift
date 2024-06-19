//
//  NoteDetailViewController.swift
//  note
//
//  Created by MacBook Pro on 07/05/2024.
//

import UIKit
import CoreData

enum TypeOfView {
    case newNote
    case noteDetail
}

final class NoteDetailViewController: UIViewController {

    var id: String = ""
    
    var typeOfView: TypeOfView = .newNote
    
    @IBOutlet private weak var noteDetailTV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
    }
    
    func render() {
        
        if (self.typeOfView == .newNote)
        {return}
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
        {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", self.id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let data = result.first as? NSManagedObject
            
            self.noteDetailTV.text = data?.value(forKey: "detail") as! String
        } catch {
            debugPrint("Failed")
        }
    }

    @IBAction func tapSave(_ sender: Any) {
        debugPrint("did tap save")
        if (typeOfView == .newNote) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
            {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            guard let note = NSEntityDescription.entity(forEntityName: "Note", in: managedContext) else
            {return}
            let newNote = NSManagedObject(entity: note, insertInto: managedContext)
            let timeStamp = Date().timeIntervalSince1970
            newNote.setValue("\(timeStamp)", forKeyPath: "id")
            newNote.setValue(noteDetailTV.text, forKeyPath: "detail")
            do {
                try managedContext.save()
            } catch {
                debugPrint("Failed")
            }
            navigationController?.popViewController(animated: true)
        } else {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else
            {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "id = %@", self.id)
            
            do {
                let note = try managedContext.fetch(fetchRequest)
                
                let noteToUpdate = note.first as? NSManagedObject
                
                noteToUpdate?.setValue(self.noteDetailTV.text, forKey: "detail")
                
                do {
                    try managedContext.save()
                } catch {
                    debugPrint("Save Failed")
                }
            } catch {
                debugPrint("Failed")
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
