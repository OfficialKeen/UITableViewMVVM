//
//  TodoItemTableViewCell.swift
//  TableViewMVVM
//
//  Created by Keen on 01/03/20.
//  Copyright © 2020 iosapp. All rights reserved.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {

    @IBOutlet weak var txtIndex: UILabel!
    @IBOutlet weak var txtTodoItem: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withViewModel viewModel: TodoItemPresentable) -> (Void) {
        txtIndex.text = viewModel.id!
        
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: viewModel.textValue!)
        if viewModel.isDone! {
            let range = NSMakeRange(0, attributeString.length)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.lightGray, range: range)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: range)
            attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: range)
        }
        txtTodoItem.attributedText = attributeString
    }
}
