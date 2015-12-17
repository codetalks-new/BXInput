//
//  ViewController.swift
//  BXInput
//
//  Created by banxi1988 on 12/17/2015.
//  Copyright (c) 2015 banxi1988. All rights reserved.
//

import UIKit
import BXModel
import BXInput

extension String:BXBasicItemAware{
  public var bx_text:String{return self}
  public var bx_detailText:String{return self}
}

class ViewController: UITableViewController {
  
  
  override func loadView() {
    super.loadView()
  }

  var adapter:SimpleTableViewAdapter<String>?
    override func viewDidLoad() {
        super.viewDidLoad()
      adapter = SimpleTableViewAdapter(tableView: tableView,cellStyle : .Subtitle)
      adapter?.updateItems(Repeat(count: 15, repeatedValue: "Copyright (c) 2015 banxi1988. All rights reserved."))
      adapter?.configureCellBlock = {
        cell,index in
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
      }
      tableView.rowHeight = UITableViewAutomaticDimension
      tableView.estimatedRowHeight = 60
      tableView.keyboardDismissMode = .OnDrag
      
      BXInputToolBar.sharedInputBar.show()
      
      tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: BXInputToolBar.Settings.preferedHeight, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

  override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
      NSLog("\(__FUNCTION__) \(previousTraitCollection)")
    BXInputToolBar.sharedInputBar.traitCollectionDidChange(previousTraitCollection)
    
  }
}

