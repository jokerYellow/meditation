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
    var trigger : ((UITableViewCell)->Void)?
}

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    
    let tableView = UITableView.init(frame: .zero, style: .grouped)
    
    lazy var sources : [SettingItemGroup] = {
        let workTimes = [5,8,10,15,20,25,30,35,40]
        let breakTimes = [1,2,3,5,8,10]
        let points = [1,2,3,4,5,6,7,8,9,10]
        let theme = SettingItemGroup.init(title: NSLocalizedString("Theme",comment: ""),
                              items: [
        SettingItem.init(title: NSLocalizedString("Current Theme",comment: ""),
                         value: {
                            return ThemeManager.shared.theme.description
        },
                         trigger: { [unowned self] cell in
                            let alert = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
                            
                            let change : (ThemeManager.Theme,UITableViewCell)->Void = { [unowned self](theme,cell) in
                                ThemeManager.shared.theme = theme
                                guard let index = self.tableView.indexPath(for: cell) else {
                                    return
                                }
                                self.tableView.reloadRows(at: [index], with: .none)
                            }
                            
                            alert.addAction(UIAlertAction.init(title: ThemeManager.Theme.dark.description, style: .default, handler: { (_) in
                                change(.dark,cell)
                            }))
                            alert.addAction(UIAlertAction.init(title: ThemeManager.Theme.light.description, style: .default, handler: { (_) in
                                change(.light,cell)
                            }))
                            alert.addAction(UIAlertAction.init(title: ThemeManager.Theme.system.description, style: .default, handler: { (_) in
                                change(.system,cell)
                            }))
                            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
                                                                   
                            }))
                            alert.popoverPresentationController?.sourceView = cell
                            self.present(alert, animated: true, completion: nil)
        })])
        let other = SettingItemGroup.init(title: NSLocalizedString("其他",comment: ""),
        items: [
            SettingItem.init(title: NSLocalizedString("微博",comment: ""),
                             trigger: { _ in
                                UIApplication.shared.open(URL.init(string: "https://weibo.com/u/2178539252")!, options:[UIApplication.OpenExternalURLOptionsKey : Any](), completionHandler: nil)
            }),
            SettingItem.init(title: NSLocalizedString("分享给其他小伙伴",comment: ""),
                             trigger: {[unowned self] cell in
                                self.share(sourceView: cell)
            }),
            SettingItem.init(title: NSLocalizedString("版本号",comment: ""),
                             accessoryType: .none,
                             value: {
                                return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            })])
        var items = [
            SettingItemGroup.init(title: NSLocalizedString("番茄钟", comment: "番茄钟"),
                                              items: [
                                                SettingItem.init(
                                                    title: NSLocalizedString("工作时长",comment: ""),
                                                    value: {[unowned self] in
                                                        return "\(self.config.workTime.minutes) \(NSLocalizedString("分钟",comment: ""))"
                                                    },
                                                    trigger: { [unowned self] _ in
                                                        let picker :Picker = PickerView()
                                                        picker.show(title: NSLocalizedString("工作时长",comment: ""), items: workTimes.map{"\($0)"}, dw: NSLocalizedString("分钟",comment: ""),defaultIndex: workTimes.firstIndex(of: self.config.workTime.minutes) ?? 0) { (index) in
                                                        self.config.workTime = workTimes[index].seconds
                                                        Util.saveInfo(info: self.config, t: .config)
                                                        self.tableView.reloadData()
                                                        }
                                                    }
                                                ),
                                                SettingItem.init(
                                                    title: NSLocalizedString("短休息时长",comment: ""),
                                                    value: {[unowned self] in
                                                        return "\(self.config.breakTime.minutes) \(NSLocalizedString("分钟",comment: ""))"
                                                    },
                                                    trigger: { [unowned self] _ in
                                                        let picker :Picker = PickerView()
                                                        picker.show(title: NSLocalizedString("短休息时长",comment: ""), items: breakTimes.map{"\($0)"}, dw: NSLocalizedString("分钟",comment: ""),defaultIndex: breakTimes.firstIndex(of: self.config.breakTime.minutes) ?? 0) { (index) in
                                                        self.config.breakTime = breakTimes[index].seconds
                                                        Util.saveInfo(info: self.config, t: .config)
                                                        self.tableView.reloadData()
                                                     }
                                                 }),
                                                SettingItem.init(
                                                    title: NSLocalizedString("长休息时长",comment: ""),
                                                    value: {[unowned self] in
                                                        return "\(self.config.longBreakTime.minutes) \(NSLocalizedString("分钟",comment: ""))"},
                                                    trigger: { [unowned self] _ in
                                                        let picker :Picker = PickerView()
                                                        picker.show(title: NSLocalizedString("长休息时长",comment: ""), items: breakTimes.map{"\($0)"}, dw: NSLocalizedString("分钟",comment: ""),defaultIndex: breakTimes.firstIndex(of: self.config.longBreakTime.minutes) ?? 0) { (index) in
                                                        self.config.longBreakTime = breakTimes[index].seconds
                                                        Util.saveInfo(info: self.config, t: .config)
                                                        self.tableView.reloadData()
                                                    }
                                                }),
                                                SettingItem.init(
                                                    title: NSLocalizedString("循环次数",comment: ""),
                                                    value: {[unowned self] in
                                                        return "\(self.config.workPoint) \(NSLocalizedString("次",comment: ""))"},
                                                   trigger: { [unowned self] _ in
                                                       let picker :Picker = PickerView()
                                                       picker.show(title:NSLocalizedString("循环次数",comment: ""), items: points.map{"\($0)"}, dw: NSLocalizedString("次",comment: ""),defaultIndex: points.firstIndex(of: self.config.workPoint) ?? 0) { (index) in
                                                       self.config.workPoint = points[index]
                                                       Util.saveInfo(info: self.config, t: .config)
                                                       self.tableView.reloadData()
                                                    }})
                                                    ]),
        ]
        if #available(iOS 13.0, *)  {
            items.append(theme)
        }
        items.append(other)
        return items
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
        self.view.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.title = NSLocalizedString("设置",comment: "")
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
        guard let cell = tableView.cellForRow(at: indexPath) else {return}
        sources[indexPath.section].items[indexPath.row].trigger?(cell)
    }
     
    func share(sourceView:UIView) {
        let activity = UIActivityViewController.init(activityItems: [appUrl], applicationActivities: [UIActivity.init()])
        //https://stackoverflow.com/questions/25644054/uiactivityviewcontroller-crashing-on-ios-8-ipads
        //in ipad is popover style
        activity.popoverPresentationController?.sourceView = sourceView
        self.present(activity , animated: true, completion: nil)
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
