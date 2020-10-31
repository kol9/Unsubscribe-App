//
//  ViewController.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 01.03.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
import AudioToolbox
import VK_ios_sdk


class ViewController: UIViewController {
    
    
    let VK_APP_ID = "7340939"
    let scope = ["groups"]
    var sdkInstance: VKSdk!
    let loader = ImageLoader()
    
    
    var groupOpenID = 0
    
    var isEditMode = false
    
    var selectedCells: Set<IndexPath> = []
    
    @IBOutlet weak var unsubscribeButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    var data: [Group] = []
    
    private let spacing: CGFloat = 12
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var pickedGroupCounter: UILabel!
    
    func getGroups() {
        data = []
        guard let currentUserId = VKSdk.accessToken()?.userId else {
            return
        }
        
        /*
         deactivated
         string    возвращается в случае, если сообщество удалено или заблокировано. Возможные значения:
         deleted — сообщество удалено;
         banned — сообщество заблокировано;
         */
        
        let req = VKApi.request(withMethod: "groups.get", andParameters: [
            "user_id": currentUserId,
            "extended" : "1",
            "fields" : ["is_hidden_from_feed","description", "members_count","deactivated"]
        ])
        
        req?.execute(resultBlock: { [self]
            result in
            
            
            let arr = result?.json as! NSDictionary
            print(arr)
            
            guard let groupsCount = arr["count"] as? Int else {
                return
            }
            
            guard let groups = arr["items"] as? NSArray else{
                return
            }
            for i in 0..<groupsCount {
                
                guard let currentGroup = groups[i] as? NSDictionary else {
                    continue
                }
                
                
                guard let id = currentGroup["id"] as? Int else {
                    continue
                }
                
                guard let name = currentGroup["name"] as? String else {
                    continue
                }
                
                guard let membersCount = currentGroup["members_count"] as? Int else {
                    continue
                }
                
                
                guard let description = currentGroup["description"] as? String else {
                    continue
                }
                
                guard let imageURL = currentGroup["photo_200"] as? String else {
                    continue
                }
                
                guard let isHidden = currentGroup["is_hidden_from_feed"] as? Int else {
                    continue
                }
                
                guard let deactivated = currentGroup["deactivated"] as? String? else {
                    return
                }
                
                
                self.data.append(Group(name: name, id: id, description: description, membersCount: membersCount, imageURL: imageURL, isHidden: isHidden, friends: nil, lastPost: nil, deactivated: deactivated))
                
            }
            self.removeSpinner()
            self.collectionView.reloadData()
        }, errorBlock: {
            error in
            print("error",error)
        })
    }
    
    

    
    
    
    func getFriends(id: Int, index: Int) {
        let req = VKApi.request(withMethod: "groups.getMembers", andParameters: [
            "group_id": String(id),
            "filter" : "friends",
            "count": 0
        ])
        
        if data.count <= index {
            return
        }
        
        if data[index].friends != nil {
            return
        }
        
        req?.execute(resultBlock: { result in
            let dict = result?.json as! NSDictionary
            guard let friends = dict["count"] as? Int else {
                return
            }
            if self.data.count <= index {
                return
            }
            self.data[index].friends = friends
        }, errorBlock: {
            error in
            print("error",error)
        })
    }
    
    
    func getLastPost(id: Int, index: Int) {
        
        let req = VKApi.request(withMethod: "wall.get", andParameters: [
            "owner_id": -id,
            "count": 1
        ])
        
        if data.count <= index {
            return
        }
        
        if data[index].lastPost != nil {
            return
        }
        
        req?.execute(resultBlock: { result in
            let dict = result?.json as! NSDictionary
//            print(dict)
            guard let arr = dict["items"] as? NSArray else {
                return
            }
            
            
            if arr.count == 0 {
                return
            }
            
            guard let post = arr[0] as? NSDictionary else {
                return
            }
            
            
            guard let lastPost = post["date"] as? Int else {
                return
            }
            
        
            let date = Date(timeIntervalSince1970: TimeInterval(lastPost))
            print("int: \(lastPost) date: \(date), index: \(index), id: \(id)")
            if self.data.count <= index {
                return
            }
            self.data[index].lastPost = date
        }, errorBlock: {
            error in
            print("error",error)
        })
    }
    
    @objc func auth() {
        VKSdk.wakeUpSession(scope, complete: {(state: VKAuthorizationState, error: Error?) in
            if state == .authorized {
                print("Authorized and ready to go ")
                self.getGroups()
            } else if error == nil{
                VKSdk.authorize(self.scope)
            } else {
                print("Error")
                return
            }
        })
    }
    
    var longPressGR: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkInstance = VKSdk.initialize(withAppId: VK_APP_ID)
        sdkInstance.register(self)
        sdkInstance.uiDelegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GroupCell.self, forCellWithReuseIdentifier: "groupCell")
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 100, right: 0)
        
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // this is the replacement of implementing: "collectionView.addSubview(refreshControl)"
//        collectionView.refreshControl = refreshControl
        //        let rec = UITapGestureRecognizer(target: self, action: #selector(upd))
//        self.view.addGestureRecognizer(rec)
        
        cancelButton.addTarget(self, action:#selector(cancelEditing), for: .touchUpInside)
        unsubscribeButton.addTarget(self, action: #selector(unsubscribe), for: .touchUpInside)
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        longPressGR.minimumPressDuration = 0.3
        longPressGR.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressGR)
        
        collectionView.alwaysBounceVertical = true
        
        editModeFinished()
    }
    
    
    
//    @objc func refresh(refreshControl: UIRefreshControl) {
//        print("Refresh")
        
        
//        data = []
//        collectionView.reloadData()
//        auth()
        
        // somewhere in your code you might need to call:
//        refreshControl.endRefreshing()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showSpinner(onView: self.view)
        auth()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }
    
    @objc func cancelEditing() {
        editModeFinished()
    }

    
    
    @objc func singleUnsubscribe() {
        self.children[0].view.removeFromSuperview()
        self.children[0].didMove(toParent: self)
        self.showSpinner(onView: self.view)
        
        
        var cnt = 0
        DispatchQueue.global().async {
            let req = VKApi.request(withMethod: "groups.leave", andParameters: [
                "group_id": self.groupOpenID,
            ])
            
            req?.execute(resultBlock: {
                responce in
                cnt = 1
                print("Unsubscribed from \(self.groupOpenID)")
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
//            DispatchQueue.main.async {
//                self.editModeFinished()
//            }
            
            self.getGroups()
        }
    }
    
    @objc func unsubscribe() {
        self.editView.isHidden = true
        self.showSpinner(onView: self.view)
    
        
        
        var cnt = 0
        for i in selectedCells {
            DispatchQueue.global().async {
                let req = VKApi.request(withMethod: "groups.leave", andParameters: [
                    "group_id": self.data[i.item].id,
                ])
                
                req?.execute(resultBlock: {
                    responce in
                    
                    cnt += 1
                    print("Unsubscribed from \(self.data[i.item].id)")
                }, errorBlock: {
                    error in
                    cnt += 1
                    print(error)
                })
            }
        }
        
        DispatchQueue.global().async {
            while(true) {
                sleep(100)
                if cnt == self.selectedCells.count {
                    break
                }
            }
            DispatchQueue.main.async {
                self.editModeFinished()
            }
            
            self.getGroups()
        }
    }
    
    
    func editModeStarted() {
        longPressGR.isEnabled = false
        editView.isHidden = false
        isEditMode = true
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 150, right: 0)
//        collectionView.isEditing = true
    }
    
    
    
    func editModeFinished() {
        
        for i in selectedCells {
            guard let cell = collectionView.cellForItem(at: i) as? GroupCell else {
                continue
            }
            cell.isPicked = false
        }
        
        selectedCells = []
        longPressGR.isEnabled = true
        editView.isHidden = true
        isEditMode = false
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 100, right: 0)
//        collectionView.isEditing = false
        collectionView.reloadData()
    }
    
    @objc
    func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
//        if longPressGR.state != .recognized {
//            return
//        }
        
        let point = longPressGR.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let indexPath = indexPath {
            var cell = self.collectionView.cellForItem(at: indexPath)
            if indexPath.section == 0 {
                
            } else {
                
                let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedbackgenerator.prepare()
                impactFeedbackgenerator.impactOccurred()
                editModeStarted()
                let cell = cell as! GroupCell
                selectedCells.insert(indexPath)
//                cell.isPicked = true
                
                pickedGroupCounter.text = "\(selectedCells.count)"
            }
            
            print(indexPath.item)
        } else {
            print("Could not find index path")
        }
    }
}


extension ViewController: VKSdkDelegate, VKSdkUIDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if ((result.token) != nil) {
            print(result.token!)
        } else if ((result.error) != nil) {
            return
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("vkSdkUserAuthorizationFailed")
    }
    
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("vkSdkShouldPresent")
        if (self.presentedViewController != nil) {
            self.dismiss(animated: true, completion: {
                print("hide current modal controller if presents")
                self.present(controller, animated: true, completion: {
                    print("SFSafariViewController opened to login through a browser")
                })
            })
        } else {
            self.present(controller, animated: true, completion: {
                print("SFSafariViewController opened to login through a browser")
            })
        }
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("vkSdkNeedCaptchaEnter")
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        
        if section != 0 {
            return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        } else {
            return UIEdgeInsets(top: 0, left: spacing, bottom: spacing, right: spacing)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: 250, height: 136)
        }
        let numberOfItemsPerRow:CGFloat = 3
        let spacingBetweenCells:CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing) / numberOfItemsPerRow
            let height = CGFloat(158)
            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
    
}


extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath) as! GroupCell
            
            let group = data[indexPath.item]
            cell.setTitle(data[indexPath.item].name)
            
            let q = DispatchQueue(label: "q", attributes: .concurrent)
            q.async {
                self.getLastPost(id: group.id, index: indexPath.item)
            }
            
            
            let q2 =  DispatchQueue(label: "q2", attributes: .concurrent)

            q2.async {
                self.getFriends(id: group.id, index: indexPath.item)
            }
            
            let url = URL(string: data[indexPath.item].imageURL)
            let token = self.loader.loadImage(url!) { result in
                do {
                    let image = try result.get()
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                } catch {
                    print(error)
                }
            }
            
            if selectedCells.contains(indexPath) {
                cell.isPicked = true
            }
            cell.onReuse = {
                if let token = token {
                    self.loader.cancelLoad(token)
                }
            }
            return cell
        }
    }
    
    
    
    @objc func openGroup() {
        guard let url = URL(string: "https://vk.com/public\(groupOpenID)") else { return }
        UIApplication.shared.open(url)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if !isEditMode {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "UIBottom") as? BottomViewController
            else {
                return
            }
            vc.closeClosure = {
                vc.view.removeFromSuperview()
                self.children[0].didMove(toParent: self)
            }
            addChild(vc)
            view.addSubview(vc.view)
            
            
            vc.groupNameLabel.text = data[indexPath.item].name
            vc.descriptionLabel.text = data[indexPath.item].description
            if data[indexPath.item].description == "" {
                vc.descriptionLabel.text = "Описание отсутствует"
            }
            
            var friends = "-"
            
            if let f = data[indexPath.item].friends {
                friends = String(f)
            }
            
            
            
            
            
            vc.membersLabel.text = "\(data[indexPath.item].membersCount) подписчиков · \(friends) друзей"
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd MMMM, yyyy"
            
            
            if let date = data[indexPath.item].lastPost {
                vc.lastPostLabel.text = "Последняя запись \(dateFormatter.string(from: date))г."
            } else {
                vc.lastPostLabel.text = "Последняя запись -"
            }
            
            groupOpenID = data[indexPath.item].id
            vc.openButton.addTarget(self, action: #selector(openGroup), for: .touchUpInside)
            vc.unsubscribeButton.addTarget(self, action: #selector(singleUnsubscribe), for: .touchUpInside)
            
            children[0].didMove(toParent: self)
            print(indexPath.item)
        } else {
            var cell = self.collectionView.cellForItem(at: indexPath)
            if indexPath.section == 0 {
                
            } else {
//                collectionView.isEditing = true
                let cell = cell as! GroupCell
//                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
                impactFeedbackgenerator.prepare()
                impactFeedbackgenerator.impactOccurred()
                
                if !cell.isPicked {
                    cell.isPicked = true
                    selectedCells.insert(indexPath)
                } else {
                    cell.isPicked = false
                    selectedCells.remove(indexPath)
                }
                pickedGroupCounter.text = "\(selectedCells.count)"
            }
        }
    }
    
}



