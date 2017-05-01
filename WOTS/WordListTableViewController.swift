//
//  WordListTableViewController.swift
//  WOTS
//
//  Created by Jade Huang on 4/30/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation

import UIKit

class WordListTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    let fullView: CGFloat = 100
    
    var partialView: CGFloat {
        return UIScreen.main.bounds.height - 150
    }
    
    var words: [String] = ["We", "Heart", "Swift"]
    
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(WordListViewController.panGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        tableView.register(UINib(nibName: "DefaultTableViewCell", bundle: nil), forCellReuseIdentifier: textCellIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .dark)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height - 200
            self?.view.frame = CGRect(x:0, y:yComponent, width:frame!.width, height:frame!.height)
        }
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        
        let y = self.view.frame.minY
        if (y + translation.y >= fullView) && (y + translation.y <= partialView) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
                if recognizer.state == .ended {
                    var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
        
                    duration = duration > 1.3 ? 1 : duration
        
                    UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                        if  velocity.y >= 0 {
                            self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                        } else {
                            self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                        }
        
                    }, completion: { [weak self] _ in
                        if ( velocity.y < 0 ) {
                            self?.tableView.isScrollEnabled = true
                        }
                    })
                }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: TableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("total of #\(self.words) words")
        return self.words.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: textCellIdentifier)!
        
        cell.textLabel?.text = self.words[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    // MARK - Gesture recognizer
    
    // Solution
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
        let direction = gesture.velocity(in: view).y
        
        let y = view.frame.minY
        if (y == fullView && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
            tableView.isScrollEnabled = false
        } else {
            tableView.isScrollEnabled = true
        }
        
        return false
    }
    
}
