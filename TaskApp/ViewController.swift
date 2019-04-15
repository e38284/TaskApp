//
//  ViewController.swift
//  TaskApp
//
//  Created by 萩原祐太郎 on 2019/03/30.
//  Copyright © 2019 Yutaro_Hagiwara. All rights reserved.
//

import UIKit
import RealmSwift   // データベース
import UserNotifications    // ローカル通知


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {


    @IBOutlet weak var categorySearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    
    // Realmインスタンスを取得する
    let realm = try! Realm()  
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    lazy var searchResults = realm.objects(Task.self).filter("category == %@", categorySearchBar.text!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // サーチバーのデリゲート
        categorySearchBar.delegate = self
        // テーブルビューのデリゲート・データソース
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categorySearchBar.text != "" {
            return searchResults.count
        } else {
            return taskArray.count
        }
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        self.searchResults = realm.objects(Task.self).filter("category == %@", categorySearchBar.text!)
        print("反応してる？")
        self.tableView.reloadData()
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
        self.tableView.reloadData()
    }

    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
//        let taskCell = taskArray[indexPath.row]
        
        if categorySearchBar.text != "" {
            // Cellに値を設定する
            // Cellに表示されるタイトルを”textLabel”にて設定
            cell.textLabel?.text = searchResults[indexPath.row].title
            // Cellに表示される日付を”detailTextLabel”にて設定
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString:String = formatter.string(from: searchResults[indexPath.row].date)
            cell.detailTextLabel?.text = dateString
        } else {
            cell.textLabel?.text = taskArray[indexPath.row].title
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString:String = formatter.string(from: taskArray[indexPath.row].date)
            cell.detailTextLabel?.text = dateString
        }
            
        return cell
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    // MARK: UITableViewDelegateプロトコルのメソッド
    // セルをタップした時にタスク入力画面に遷移させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Deleteボタンが押されたときにローカル通知をキャンセルし、データベースからタスクを削除する
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    // タスク入力画面に遷移する際にデータを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        // 作成済みのタスクを編集するとき
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        //新しいタスクを作成するとき
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // タスク入力画面から戻ってきた時にTableViewの情報を更新する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }


}
