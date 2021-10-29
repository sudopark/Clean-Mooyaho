//
//  NotificationViewController.swift
//  ReadReminderNotificationExtension
//
//  Created by sudo.park on 2021/10/30.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }

}
