//
//  SecondViewController.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 31.10.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
import VK_ios_sdk

class SecondViewController: UIViewController {
    
    
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    var data: [Group] = []
    var text: [[String]] = []
    let loader = ImageLoader()
    
    var badGroups: ([Group], [[String]]){
        get {
            var arr: [Group] = []
            var descr: [[String]] = []
            for group in globalGroups {
                
                var str:[String] = []
                var added = false
                if group.isHidden == 1 {
                    if !added {
                        arr.append(group)
                        added = true
                    }
                    str.append("- Записи сообщества не показываются в вашей ленте")
                }
                
                
                if let deac = group.deactivated {
                    if deac == "deleted" || deac == "banned" {
                        if !added {
                            arr.append(group)
                            added = true
                        }
                        str.append("- Сообщество закрыто или заблокированно\n")
                    }
                }
                
                if let lastPost = group.lastPost {
                    let diff = Date().timeIntervalSince(lastPost)
//                    let diff: TimeInterval = Date() - lastPost
                    let time = Int(diff)
                    let years = (time / 3600) / 24 / 365
                    if years > 1 {
                        if !added {
                            arr.append(group)
                            added = true
                        }
                        str.append("- В сообществе давно не было записей")
                    }
                }
                if str.count != 0 {
                    descr.append(str)
                }
            }
            
            return (arr, descr)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
//        tableView.delegate = self
        tableView.separatorStyle = .none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 136;
        tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        // Do any additional setup after loading the view.
    }
    
    
    @objc func refresh() {
//        refreshControl.beginRefreshing()
        let bad = badGroups
        data = bad.0
        data = bad.0
        text = bad.1
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bad = badGroups
        data = bad.0
        data = bad.0
        text = bad.1
        tableView.reloadData()
    }
}


extension SecondViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "topCelltv", for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCelltv", for: indexPath) as! MainCell
            cell.groupNameLabel.text = data[indexPath.row].name
            
            
            cell.onTap = {
                self.showSpinner(onView: cell.leaveButton, UIColor(red: 73.0 / 255.0, green: 134.0 / 255.0, blue: 204.0 / 255.0, alpha: 1))
                var cnt = 0
                DispatchQueue.global().async {
                    let id = self.data[indexPath.row].id
                    let req = VKApi.request(withMethod: "groups.leave", andParameters: [
                        "group_id": id,
                    ])

                    req?.execute(resultBlock: {
                        responce in
                        print("Unsubscribed from \(id)")
                        cnt = 1
                    }, errorBlock: {
                        error in
                        cnt = 1
                        print(error)
                    })
                }
                
                DispatchQueue.global().async {
                    while(true) {
        //                sleep(100)
                        if cnt == 1 {
                            break
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.data.remove(at: indexPath.row)
                        self.text.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        tableView.reloadData()
//                        self.children[0].view.removeFromSuperview()
//                        self.children[0].didMove(toParent: self)
                        self.removeSpinner()
//                        self.getGroups()
        //                self.refreshControl.beginRefreshing()
                    }
                    
                    
        //            self.getGroups()
                }
            }
            
            if cell.groupLogo.image == nil {
                let url = URL(string: data[indexPath.row].imageURL)
                let token = self.loader.loadImage(url!) { result in
                    do {
                        let image = try result.get()
                        self.data[indexPath.row].image = image
                        DispatchQueue.main.async {
                            cell.groupLogo.image = image
                        }
                    } catch {
                        print(error)
                    }
                }
                
                cell.onReuse = {
                    if let token = token {
                        self.loader.cancelLoad(token)
                    }
                }
            
            } else {
                cell.groupLogo.image = data[indexPath.row].image
            }
            

            var str = ""
            
//            print(text)
            for s in text[indexPath.row] {
//                print(s)
                str += s
                str += "\n"
            }
            
            
            cell.groupConsLabel.text = str
            return cell
        }
        
    }
  
}
