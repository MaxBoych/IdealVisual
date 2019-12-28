//
//  ProfileProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileDelegate: class {
    func chooseAvatar(picker: UIImagePickerController)
    func showAlert(alert: UIAlertController)
    func dismissAlert()
    func enableTabBarButton()
    func logOut()
}
