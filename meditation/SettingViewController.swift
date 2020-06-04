//
//  SettingViewController.swift
//  meditation
//
//  Created by HuangYaqing on 2020/5/27.
//  Copyright © 2020 HuangYaqing. All rights reserved.
//

import UIKit

struct SettingItemGroup{
    var title : String
    var items :[SettingItem]
}

struct SettingItem {
    var title : String
    var accessoryType : UITableViewCell.AccessoryType = .disclosureIndicator
    var value : (()->String)?
    var trigger : (()->Void)?
}

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    
    let tableView = UITableView.init(frame: .zero, style: .grouped)
    
    lazy var sources : [SettingItemGroup] = {
        let workTimes = [5,8,10,15,20,25,30,35,40]
        let breakTimes = [1,2,3,5,8,10]
        let points = [1,2,3,5,8,10]
        return [
                SettingItemGroup.init(title: "番茄钟",
                                      items: [
                                        SettingItem.init(
                                            title: "工作时长",
                                            value: {[unowned self] in
                                                return "\(self.config.workTime.minutes) 分钟"
                                            },
                                            trigger: { [unowned self] in
                                                let picker :Picker = PickerView()
                                                picker.show(title: "工作时长", items: workTimes.map{"\($0)"}, dw: "分钟",defaultIndex: workTimes.firstIndex(of: self.config.workTime.minutes) ?? 0) { (index) in
                                                self.config.workTime = workTimes[index].seconds
                                                Util.saveInfo(info: self.config, t: .config)
                                                self.tableView.reloadData()
                                                }
                                            }
                                        ),
                                        SettingItem.init(
                                            title: "短休息时长",
                                            value: {[unowned self] in
                                                return "\(self.config.breakTime.minutes) 分钟"
                                            },
                                            trigger: { [unowned self] in
                                                let picker :Picker = PickerView()
                                                picker.show(title: "短休息时长", items: breakTimes.map{"\($0)"}, dw: "分钟",defaultIndex: breakTimes.firstIndex(of: self.config.breakTime.minutes) ?? 0) { (index) in
                                                self.config.breakTime = breakTimes[index].seconds
                                                Util.saveInfo(info: self.config, t: .config)
                                                self.tableView.reloadData()
                                             }
                                         }),
                                        SettingItem.init(
                                            title: "长休息时长",
                                            value: {[unowned self] in
                                                return "\(self.config.longBreakTime.minutes) 分钟"},
                                            trigger: { [unowned self] in
                                                let picker :Picker = PickerView()
                                                picker.show(title: "长休息时长", items: breakTimes.map{"\($0)"}, dw: "分钟",defaultIndex: breakTimes.firstIndex(of: self.config.longBreakTime.minutes) ?? 0) { (index) in
                                                self.config.longBreakTime = breakTimes[index].seconds
                                                Util.saveInfo(info: self.config, t: .config)
                                                self.tableView.reloadData()
                                            }
                                        }),
                                        SettingItem.init(
                                            title: "循环次数",
                                            value: {[unowned self] in
                                                return "\(self.config.workPoint.minutes) 次"},
                                           trigger: { [unowned self] in
                                               let picker :Picker = PickerView()
                                               picker.show(title: "循环次数", items: points.map{"\($0)"}, dw: "次",defaultIndex: points.firstIndex(of: self.config.workPoint.minutes) ?? 0) { (index) in
                                               self.config.workPoint = points[index].seconds
                                               Util.saveInfo(info: self.config, t: .config)
                                               self.tableView.reloadData()
                                            }})
                                            ]),
                SettingItemGroup.init(title: "主题",
                items: [SettingItem.init(title: "工作结束提醒音"),
                        SettingItem.init(title: "休息结束提醒音"),
                        SettingItem.init(title: "背景图片切换"),
                        SettingItem.init(title: "背景音乐切换"),
                        SettingItem.init(title: "动画切换")]),
                SettingItemGroup.init(title: "其他",
                items: [SettingItem.init(title: "关于我们"),
                        SettingItem.init(title: "版本号",accessoryType: .none)]),
        ]
    }()
    
    var config :Config = {
        let config :Config? = Util.readInfo(tp: .config)
        return config ?? Config()
    }(){
        didSet{
            Meditation.shared.config = self.config
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = "设置"
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.bottom.trailing.equalTo(self.view)
        }
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = sources[indexPath.section].items[indexPath.row].title
        cell.detailTextLabel?.text = sources[indexPath.section].items[indexPath.row].value?()
        cell.accessoryType = sources[indexPath.section].items[indexPath.row].accessoryType
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sources.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sources[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sources[indexPath.section].items[indexPath.row].trigger?()
    }
     
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
