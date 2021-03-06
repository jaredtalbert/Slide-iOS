//
//  CacheSettings.swift
//  Slide for Reddit
//
//  Created by Carlos Crane on 5/22/18.
//  Copyright © 2018 Haptic Apps. All rights reserved.
//

import UIKit

class CacheSettings: UITableViewController {

    var subs: [String] = []
    var autoCache: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "auto")
    var cacheContent: UITableViewCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cache")

    var autoCacheSwitch = UISwitch()
    var cacheContentSwitch = UISwitch()

    public func createCell(_ cell: UITableViewCell, _ switchV: UISwitch? = nil, isOn: Bool, text: String) {
        cell.textLabel?.text = text
        cell.textLabel?.textColor = ColorUtil.fontColor
        cell.backgroundColor = ColorUtil.foregroundColor
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        if let s = switchV {
            s.isOn = isOn
            s.addTarget(self, action: #selector(SettingsLayout.switchIsChanged(_:)), for: UIControlEvents.valueChanged)
            cell.accessoryView = s
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selected.append(contentsOf: Subscriptions.offline)
        self.tableView.register(SubredditCellView.classForCoder(), forCellReuseIdentifier: "sub")
        subs.append(contentsOf: Subscriptions.subreddits)
        self.subs = self.subs.sorted() {
            $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
        }
        tableView.reloadData()
        self.tableView.separatorStyle = .none

        createCell(autoCache, autoCacheSwitch, isOn: SettingValues.autoCache, text: "Cache subreddits automatically")
        self.autoCache.detailTextLabel?.text = "Will run the first time Slide opens each day"
        self.autoCache.detailTextLabel?.textColor = ColorUtil.fontColor
        self.autoCache.detailTextLabel?.lineBreakMode = .byWordWrapping
        self.autoCache.detailTextLabel?.numberOfLines = 0

        createCell(cacheContent, cacheContentSwitch, isOn: false, text: "Cache subreddits automatically")
        self.cacheContent.detailTextLabel?.text = "Coming soon!"
        self.cacheContent.detailTextLabel?.textColor = ColorUtil.fontColor
        self.cacheContent.detailTextLabel?.lineBreakMode = .byWordWrapping
        self.cacheContent.detailTextLabel?.numberOfLines = 0

        self.tableView.tableFooterView = UIView()
    }

    var delete = UIButton()

    public static var changed = false

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 80 : 60
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        save(nil)
    }

    func save(_ selector: AnyObject?) {
        /* todo this
        SubredditReorderViewController.changed = true
        Subscriptions.set(name: AccountController.currentName, subs: subs, completion: {
            self.dismiss(animated: true, completion: nil)
        })*/
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label: UILabel = UILabel()
        label.textColor = ColorUtil.baseAccent
        label.font = FontGenerator.boldFontOfSize(size: 20, submission: true)
        let toReturn = label.withPadding(padding: UIEdgeInsets.init(top: 0, left: 12, bottom: 0, right: 0))
        toReturn.backgroundColor = ColorUtil.backgroundColor

        switch section {
        case 0: label.text = "Caching settings"
        case 1: label.text = "Subreddits to Cache"
        default: label.text = ""
        }
        return toReturn
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(70)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: – Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : subs.count
    }

    func switchIsChanged(_ changed: UISwitch) {
        if changed == autoCacheSwitch {
            if !VCPresenter.proDialogShown(feature: true, self) {
                SettingValues.autoCache = changed.isOn
                UserDefaults.standard.set(changed.isOn, forKey: SettingValues.pref_autoCache)
            } else {
                changed.isOn = false
            }
        } else if changed == cacheContentSwitch {
            //todo this setting
        } else if !changed.isOn {
            selected.remove(at: selected.index(of: changed.accessibilityIdentifier!)!)
            Subscriptions.setOffline(subs: selected) {
            }
        } else {
            selected.append(changed.accessibilityIdentifier!)
            Subscriptions.setOffline(subs: selected) {
            }
        }
    }
    
    var selected = [String]()

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return autoCache
            } else {
                return cacheContent
            }
        } else {
            let thing = subs[indexPath.row]
            var cell: SubredditCellView?
            let c = tableView.dequeueReusableCell(withIdentifier: "sub", for: indexPath) as! SubredditCellView
            c.setSubreddit(subreddit: thing, nav: nil)
            cell = c
            cell?.backgroundColor = ColorUtil.foregroundColor
            let aSwitch = UISwitch()
            if selected.contains(thing) {
                aSwitch.isOn = true
            }
            aSwitch.accessibilityIdentifier = thing
            aSwitch.addTarget(self, action: #selector(switchIsChanged(_:)), for: UIControlEvents.valueChanged)
            c.accessoryView = aSwitch
            return cell!
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBaseBarColors()
        self.title = "Manage subreddit caching"
    }

}
