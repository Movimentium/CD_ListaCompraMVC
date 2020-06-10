//
//  ListaCompraTVC.swift
//  CD_ListaCompraMVC
//
//  Created by Miguel on 10/06/2020.
//  Copyright © 2020 Miguel Gallego Martín. All rights reserved.
//

import UIKit
import CoreData

class ListaCompraTVC: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    private let idCell = "idCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lista de la compra"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: idCell)
        tableView.rowHeight = 44
        initCoreDataStack()
        populateListaCompra()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func populateListaCompra() {
        let fr = NSFetchRequest<Articulo>(entityName: "Articulo")
        fr.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: moctx,
                                         sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        try! frc.performFetch()
    }

    // MARK: - NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        if type == .insert {
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        } else if type == .delete {
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = frc.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: idCell, for: indexPath)
        let articulo = frc.object(at: indexPath)
        cell.textLabel?.text = articulo.nombre
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.rowHeight
    }
    
    lazy var vwHeaderWithTxtF: UIView = {
        print("\(self.classForCoder) \(#function)")

        let frHeader = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.rowHeight)
        let vwHeader = UIView(frame: frHeader)
        vwHeader.backgroundColor = .lightGray
        
        var frTf = frHeader;   frTf.origin.x += 10;   frTf.origin.y += 8
        frTf.size.width -= 2 * frTf.origin.x
        frTf.size.height -= 2 * frTf.origin.y
        let tf = UITextField(frame: frTf)
        tf.backgroundColor = .white
        tf.borderStyle = .roundedRect
        tf.placeholder = "Escriba un artículo"
        tf.clearButtonMode = .always
        tf.delegate = self
        
        vwHeader.addSubview(tf)
        return vwHeader
    }()
    
    override func tableView(_ table: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        print("\(self.classForCoder) \(#function)")
        return vwHeaderWithTxtF
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                             forRowAt indexPath: IndexPath)
     {
        if editingStyle == .delete {
            let articuloAborrar = frc.object(at: indexPath)
            moctx.delete(articuloAborrar)
            saveContext()
        }
        tableView.isEditing = false
    }
 
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let str = textField.text, str.trimmingCharacters(in: .whitespaces).isEmpty == false {
            let articulo = NSEntityDescription.insertNewObject(forEntityName: "Articulo", into: moctx) as! Articulo
            articulo.nombre = str
            saveContext()
        }
        textField.text = nil
        return resignFirstResponder()
    }

    
    // MARK: - Core Data Stack
    
    private var moctx: NSManagedObjectContext!
    private var frc: NSFetchedResultsController<Articulo>!
    
    private func initCoreDataStack() {
        // Managed Object Model
        let modelFileURL = Bundle.main.url(forResource: "ListaCompra", withExtension: "momd")!
        let mom = NSManagedObjectModel(contentsOf: modelFileURL)!
        
        // Persistent Store Coordinator
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        let appDocsDirURL:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let storeFileURL = appDocsDirURL.appendingPathComponent("ListaCompra.sqlite")
        print("storeFileURL: \(storeFileURL)")
        let dicOpcs = [NSMigratePersistentStoresAutomaticallyOption:true]
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                    configurationName: nil,
                                    at: storeFileURL, options: dicOpcs)
        
        // Managed Object Context
        moctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moctx.persistentStoreCoordinator = psc
    }

    func saveContext() {
        if moctx.hasChanges {
            do {
                try moctx.save()
            } catch {
                print("\(ListaCompraTVC.self) \(#function) ERROR:")
                print(error.localizedDescription)
                //abort()  // DANGER
            }
        }
    }
}
