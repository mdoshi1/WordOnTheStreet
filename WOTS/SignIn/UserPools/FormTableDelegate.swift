//
//  FormTableDelegate.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.16
//
//

import Foundation
import UIKit

/**
 The form table delegate class which handles loading of cells in the table.
 */
class FormTableDelegate: NSObject {
    
    var numberOfCells: Int {
        get {
            if let cells = cells {
                return cells.count
            }
            return 0
        }
    }
    
    override init() {
        super.init()
        cells = []
    }
    
    fileprivate var cells: [FormTableCell]?
    
    /**
     Inserts the cell into table as a `TableInputCell`.
     
     @param cell   the `UserPoolsCell` to be inserted into table as a row
     */
    func add(cell: FormTableCell) {
        self.cells?.append(cell)
    }
    
}

// MARK:- UITableViewDelegate

extension FormTableDelegate: UITableViewDelegate {
    
    /**
     Fetches the value entered by the user in the row.
     
     @param tableView the tableView object
     @param cell      the `FormTableCell` whose value is to be retrieved
     @return the string value entered by user
     */
    func getValue(_ tableView: UITableView, for cell: FormTableCell) -> String? {
        let position = cells!.index {
            $0.placeHolder! == cell.placeHolder!
        }
        let indexPath = IndexPath(item: position!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath) as! TableInputCell
        return currentCell.inputBox?.text
    }
    
    /**
     Fetches the table cell for specified `FormTableCell`
     
     @param tableView the tableView object
     @param cell      the `FormTableCell` whose value is to be retrieved
     @return the `TableInputCell` object for specified `FormTableCell`
     */
    func getCell(_ tableView: UITableView, for cell: FormTableCell) -> TableInputCell? {
        let position = cells!.index {
            $0.placeHolder! == cell.placeHolder!
        }
        let indexPath = IndexPath(item: position!, section: 0)
        let currentCell = tableView.cellForRow(at: indexPath) as! TableInputCell
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let currentCell = tableView.cellForRow(at: indexPath) as! TableInputCell
        currentCell.onTap()
    }
    
}

// MARK:- UITableViewDataSource

extension FormTableDelegate : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormTableCell", for: indexPath) as! TableInputCell
        let formTableCell = cells![indexPath.row]
        cell.placeHolderLabel?.text = formTableCell.placeHolder
        cell.headerLabel?.text = formTableCell.placeHolder?.uppercased()
        cell.inputBox?.autocorrectionType = .no
        cell.inputBox?.spellCheckingType = .no
        if (formTableCell.type == InputType.password) {
            cell.inputBox?.isSecureTextEntry = true
            let showButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            showButton.setTitle("Show", for: .normal)
            showButton.addTarget(self, action: #selector(showPassword(button:)), for: .touchUpInside)
            cell.inputBox?.rightViewMode = .always
            cell.inputBox?.rightView = showButton
            showButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            showButton.setTitleColor(UIColor.darkGray, for: .normal)
        }
        if (formTableCell.type == InputType.staticText) {
            cell.placeHolderView.isHidden = true
            cell.inputBox.text = formTableCell.staticText
        }
        return cell
    }
    
    @objc func showPassword(button: UIButton) {
        let textField = button.superview as! UITextField
        if (textField.isSecureTextEntry) {
            textField.isSecureTextEntry = false
            button.setTitle("Hide", for: .normal)
        } else {
            textField.isSecureTextEntry = true
            button.setTitle("Show", for: .normal)
        }
    }
}
