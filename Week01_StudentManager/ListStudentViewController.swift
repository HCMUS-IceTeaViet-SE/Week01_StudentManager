//
//  TableViewController.swift
//  Week01_StudentManager
//
//  Created by Genius Doan on 3/13/17.
//  Copyright © 2017 IceteaViet. All rights reserved.
//

import UIKit
import  CoreData

class ListStudentViewController : UITableViewController, DetailVCDelegate {
    
    var selectedIndex: Int = 3
    static let MODE_ADD:Int = 0;
    static let MODE_EDIT:Int = 1;
    var manager:StudentManager = StudentManager()
    var appDelegate:AppDelegate?
    var objectContext:NSManagedObjectContext = NSManagedObjectContext()
    var fetchRequest:NSFetchRequest<ClassStudent> = NSFetchRequest<ClassStudent>(entityName: "ClassStudent")
    
    
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBAction func addStudent(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTableView.delegate = self
        myTableView.dataSource = self
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        manager = StudentManager()
        objectContext = (appDelegate?.persistentContainer.viewContext)!
            
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            var students = try objectContext.fetch(fetchRequest)
            
            for student in students {
                print(student)
            }
            
            manager.fetchStudentFromDb(studentArray: students)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        /*
        let entity =
            NSEntityDescription.entity(forEntityName: "ClassStudent",
                                       in: context)!
        let studentMO = NSManagedObject(entity: entity,
                                     insertInto: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ClassStudent")
        fetchRequest.returnsObjectsAsFaults = false
        */
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveData(student: Student, studentIndex: Int?, mode: Int?) {
        //Get student
        if mode == ListStudentViewController.MODE_EDIT {
            manager.updateStudent(student: student, index: studentIndex!)
            manager.updateStudentFromDb(editedIndex: studentIndex!, delegate: appDelegate!, context: objectContext, request: fetchRequest)
        }
        else
        {
            manager.addStudent(student: student)
            manager.addStudentToDb(newStudent: student, delegate: appDelegate!, context: objectContext)
        }
        myTableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return manager.getStudentList().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell

        // Configure the cell...
        if let studentName = cell.viewWithTag(100) as? UILabel
        {
            let logoImg = cell.viewWithTag(101) as! UIImageView
            logoImg.image = UIImage(named: "logo.png")
            logoImg.contentMode = UIViewContentMode.scaleAspectFill
            logoImg.layer.borderColor = UIColor(red: 231, green: 0, blue: 0, alpha: 1.0).cgColor
            logoImg.layer.borderWidth = 1
            logoImg.clipsToBounds = true
            
            cell.addSubview(logoImg)
            
            studentName.text = manager.getStudent(index: indexPath.row).firstName
            let className = cell.viewWithTag(102) as! UILabel
            className.text = manager.getStudent(index: indexPath.row).myClass.name
            
            cell.addSubview(className)
            
            cell.backgroundColor = UIColor(red: 224, green: 247, blue: 250, alpha: 1.0)
        }
        else {
            let logoImg:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            logoImg.image = UIImage(named: "logo.png")
            logoImg.contentMode = UIViewContentMode.scaleAspectFill
            logoImg.layer.borderColor = UIColor(red: 231, green: 0, blue: 0, alpha: 1.0).cgColor
            logoImg.layer.borderWidth = 1
            logoImg.clipsToBounds = true
            logoImg.tag = 101
            
            cell.addSubview(logoImg)
            
            
            let studentName:UILabel = UILabel(frame: CGRect(x: 88, y: 0, width: 240, height: 24))
            studentName.text = manager.getStudent(index: indexPath.row).firstName
            studentName.tag = 100
            cell.addSubview(studentName)
            
            
            let className:UILabel = UILabel(frame: CGRect(x: 88, y: 32, width: 240, height: 24))
            className.text = manager.getStudent(index: indexPath.row).myClass.name
            className.tag = 102
            
            cell.addSubview(className)
            
            cell.backgroundColor = UIColor(red: 224, green: 247, blue: 250, alpha: 1.0)

        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            manager.removeStudent(index: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            manager.deleteStudentFromDb(deletedIndex:indexPath.row, delegate: appDelegate!, context: objectContext, request: fetchRequest)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        var temp:Student = manager.getStudent(index: fromIndexPath.row)
        manager.removeStudent(index: fromIndexPath.row)
        manager.insertStudent(student: temp, index: to.row)
        
        //Update Core Data
        manager.updateAllStudentFromDb(delegate: appDelegate!, context: objectContext, request: fetchRequest)

    }
    
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailItemVC" {
            if let indexPath = myTableView.indexPathForSelectedRow {
                selectedIndex = indexPath.row
                let dest = segue.destination as! DetailViewController
                dest.myStudent = manager.getStudent(index: selectedIndex)
                dest.studentIndex = selectedIndex
                dest.mode = ListStudentViewController.MODE_EDIT
                dest.delegate = self
            }
            
        }
        
        if segue.identifier == "addItemVC" {
            //selectedIndex = indexPath.row
            let dest = segue.destination as! DetailViewController
            //dest.myStudent = StudentManager.studentList[selectedIndex]
            //dest.studentIndex = selectedIndex
            dest.mode = ListStudentViewController.MODE_ADD
            dest.delegate = self
        }
    }

}
