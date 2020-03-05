//
//  TodoViewModel.swift
//  TableViewMVVM
//
//  Created by Keen on 01/03/20.
//  Copyright © 2020 iosapp. All rights reserved.
//

import RxSwift

protocol TodoMenuItemViewPresentable {
    var title: String? { get set }
    var backColor: String? { get }
}

protocol TodoMenuItemViewDelegate {
    func onMenuItemSelected() -> ()
}

class TodoMenuItemViewModel: TodoMenuItemViewPresentable, TodoMenuItemViewDelegate {
    var title: String?
    var backColor: String?
    weak var parent: TodoItemViewDelegate?
    
    init(parentViewModel: TodoItemViewDelegate) {
        self.parent = parentViewModel
    }
    
    func onMenuItemSelected() {
        
    }
}

class RemoveMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        parent?.onRemoveSelected()
    }
}

class DoneMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        parent?.onDoneSelected()
    }
}

protocol TodoItemViewDelegate: class {
    func onItemSelected() -> (Void)
    func onRemoveSelected() -> (Void)
    func onDoneSelected() -> (Void)
}

protocol TodoItemPresentable {
    var id: String? { get }
    var textValue: String? { get }
    var isDone: Bool? { get set }
    var menuItems: [TodoMenuItemViewPresentable]? { get }
}

class TodoItemViewModel: TodoItemPresentable {
    var id: String? = "0"
    var textValue: String?
    var isDone: Bool? = false
    var menuItems: [TodoMenuItemViewPresentable]? = []
    weak var parent: TodoViewDelegate?
    
    init(id: String, textValue: String, parentViewModel: TodoViewDelegate) {
        self.id = id
        self.textValue = textValue
        self.parent = parentViewModel
        
        let removeMenuItem = RemoveMenuItemViewModel(parentViewModel: self)
        removeMenuItem.title = "Remove"
        removeMenuItem.backColor = "ff0000"
        
        let doneMenuItem = DoneMenuItemViewModel(parentViewModel: self)
        doneMenuItem.title = isDone! ? "Undone" : "Done"
        doneMenuItem.backColor = "008000"
        
        menuItems?.append(contentsOf: [removeMenuItem, doneMenuItem])
    }
}

extension TodoItemViewModel: TodoItemViewDelegate {
    func onItemSelected() {
        print("Did select row at received for item = \(String(describing: id))")
    }
    
    func onRemoveSelected() {
        parent?.onTodoDelete(todoId: id!)
    }
    
    func onDoneSelected() {
        parent?.onTodoDone(todoId: id!)
    }
}

protocol TodoViewDelegate: class {
    func onAddTodoItem() -> ()
    func onTodoDelete(todoId: String) -> ()
    func onTodoDone(todoId: String) -> ()
}

protocol TodoViewPresentable {
    var newTodoItem: String? { get }
}

class TodoViewModel: TodoViewPresentable {
    weak var view: TodoView?
    var newTodoItem: String?
    var items: Variable<[TodoItemPresentable]> = Variable([])
    
    init(view: TodoView) {
        self.view = view
        
        let item1 = TodoItemViewModel(id: "1", textValue: "Android Studio", parentViewModel: self)
        let item2 = TodoItemViewModel(id: "2", textValue: "C++", parentViewModel: self)
        let item3 = TodoItemViewModel(id: "3", textValue: "Swift", parentViewModel: self)
        
        items.value.append(contentsOf: [item1, item2, item3])
    }
}

extension TodoViewModel: TodoViewDelegate {
    func onAddTodoItem() {
        guard let newValue = newTodoItem else {
            print("Check Value Empty")
            return
        }
        
        let itemIndex = items.value.count + 1
        let newItem = TodoItemViewModel(id: "\(itemIndex)", textValue: newValue, parentViewModel: self)
        
        self.items.value.append(newItem)
        
        self.newTodoItem = ""
        
        self.view?.inserTodoItem()
    }
    
    func onTodoDelete(todoId: String) {
        guard let index = self.items.value.firstIndex(where: { $0.id! == todoId }) else {
            print("Index for item does not exist")
            return
        }
        
        self.items.value.remove(at: index)
        
        self.view?.removeTodoItem(at: index)
    }
    
    func onTodoDone(todoId: String) {
        guard let index = self.items.value.firstIndex(where: { $0.id! == todoId }) else {
            print("Index for item does not exist")
            return
        }
        
        var todoItem = self.items.value[index]
        todoItem.isDone = !(todoItem.isDone!)
        if var doneMenuItem = todoItem.menuItems?.filter({ (todoMenuItem) -> Bool in
            todoMenuItem is DoneMenuItemViewModel
        }).first {
            doneMenuItem.title = todoItem.isDone! ? "Undone" : "Done"
        }
        self.items.value.sort(by: {
            if !($0.isDone!) && !($1.isDone!) {
                return $0.id! < $1.id!
            }
            return !($0.isDone!) && $1.isDone!
        })
        self.view?.reloadItems()
    }
}
