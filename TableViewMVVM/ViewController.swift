//
//  ViewController.swift
//  TableViewMVVM
//
//  Created by Keen on 01/03/20.
//  Copyright © 2020 iosapp. All rights reserved.
//

import UIKit

protocol TodoView: class {
    func inserTodoItem() -> ()
    func removeTodoItem(at index: Int) -> ()
    func updateTodoItem(at index: Int) -> ()
    func reloadItems() -> ()
}

class ViewController: UIViewController {

    @IBOutlet weak var tableViewItems: UITableView!
    @IBOutlet weak var textFieldNewItem: UITextField!
    
    var identifier = "todoItemCellIndetifier"
    var viewModel: TodoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TodoItemTableViewCell", bundle: nil)
        tableViewItems.register(nib, forCellReuseIdentifier: identifier)
        
        
        viewModel = TodoViewModel(view: self)
    }

    @IBAction func onAddItem(_ sender: Any) {
        guard let newTodoValue = textFieldNewItem.text, !newTodoValue.isEmpty else {
            print("No Value Entered")
            return
        }
        viewModel?.newTodoItem = newTodoValue
        viewModel?.onAddTodoItem()
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = viewModel?.items.value else {
            return 0
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TodoItemTableViewCell
        
        let itemViewModel = viewModel?.items.value[indexPath.row]
        cell?.configure(withViewModel: itemViewModel!)
        
        return cell!
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewModel = viewModel?.items.value[indexPath.row]
        (itemViewModel as? TodoItemViewDelegate)?.onItemSelected()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        let itemViewModel = viewModel?.items.value[indexPath.row]
        
        var menuActions: [UIContextualAction] = []
        
        _ = itemViewModel?.menuItems?.map({ menuItem in
        
            let menuAction = UIContextualAction(style: .normal, title: menuItem.title!) { (action, sourceView, succes: (Bool) -> (Void)) in
                
                if let delegate = menuItem as? TodoMenuItemViewDelegate {
                    delegate.onMenuItemSelected()
                }
                succes(true)
            }
            menuAction.backgroundColor = .gray
            menuActions.append(menuAction)
        })
        return UISwipeActionsConfiguration(actions: menuActions)
    }
}

extension ViewController: TodoView {
    func inserTodoItem() {
        guard let items = viewModel?.items else {
            print("Items object is empty")
            return
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.textFieldNewItem.text = self.viewModel?.newTodoItem
            self.tableViewItems.beginUpdates()
            self.tableViewItems.insertRows(at: [IndexPath(row: items.value.count-1, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        })
    }
    
    func removeTodoItem(at index: Int) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableViewItems.beginUpdates()
            self.tableViewItems.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.tableViewItems.endUpdates()
        })
    }
    
    func updateTodoItem(at index: Int) {
        self.tableViewItems.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func reloadItems() {
        self.tableViewItems.reloadData()
    }
}
