//
//  Task.swift
//  TaskApp
//
//  Created by 萩原祐太郎 on 2019/04/02.
//  Copyright © 2019 Yutaro_Hagiwara. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // カテゴリー
    @objc dynamic var category = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    /// 日時
    @objc dynamic var date = Date()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
