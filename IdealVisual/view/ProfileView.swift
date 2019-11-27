//
//  ProfileView.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import CoreData
import Foundation
import UIKit
import Photos

protocol ProfileDelegate: class {
    func chooseAvatar(picker: UIImagePickerController)
    func showAlert(alert: UIAlertController)
    func dismissAlert()
    func enableTabBarButton()
    func logOut()
}

class ProfileView: UIView {
    private weak var delegateProfile: ProfileDelegate?
    private var testAva = UIImagePickerController()
    private let scroll = UIScrollView()
    private let labelToField = UILabel()

    private var height: NSLayoutConstraint?
    private var lineBottom = LineClose()

    private let ava = UIImageView()
    private let logoutButton = UIButton()

    private let username = InputFields(labelImage: UIImage(named: "login"), text: "ketnipz513", placeholder: nil)
    private let email = InputFields(labelImage: UIImage(named: "email"), text: "ketnipz@mail.ru", placeholder: nil)
    private let password = InputFields(labelImage: UIImage(named: "password"), text: nil, placeholder: "Пароль")
    private let repeatPassword = InputFields(labelImage: UIImage(named: "password"), text: nil,
                                             placeholder: "Повторите пароль")

    init(profileDelegate: ProfileDelegate) {
        self.delegateProfile = profileDelegate
        super.init(frame: CGRect())
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setNoEdit() {
        testAva.delegate = self
        testAva.allowsEditing = true

        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        swipe.addTarget(self, action: #selector(closeProfile))
        self.addGestureRecognizer(swipe)

        setNavButtons()
        setAva()
        setFields()
        [username, email, password, repeatPassword].forEach {
            $0.setEditFields(state: false)
        }
        password.isHidden = true
        repeatPassword.isHidden = true
        renderBottomLine()
    }

    @objc private func setEdit() {
        height?.isActive = false
        setNavEditButtons()

        height = self.heightAnchor.constraint(equalToConstant: self.bounds.height + 135)
        height?.isActive = true

        let tap = UITapGestureRecognizer()
        ava.isUserInteractionEnabled = true
        ava.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(chooseAva))
        [username, email, password, repeatPassword].forEach {
            $0.setEditFields(state: true)
        }
        setPassword()
    }

    @objc func closeProfile() {
        height?.isActive = false
        removeFromSuperview()
        delegateProfile?.enableTabBarButton()
    }

    @objc private func hide() {
        self.endEditing(true)
    }

    @objc private func save_settings() {

        setupView()
    }

    @objc private func no_settings() {
        self.removeConstraint(height!)
        setupView()
    }

    @objc private func logout() {
        delegateProfile?.logOut()
    }
}

// MARK: add view
extension ProfileView {
    func setup() {
        setupView()
    }

    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(self)
        self.widthAnchor.constraint(equalTo: (superview?.safeAreaLayoutGuide.widthAnchor)!).isActive = true
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.layer.cornerRadius = 20
        self.topAnchor.constraint(equalTo: (superview?.topAnchor)!).isActive = true
        self.leftAnchor.constraint(equalTo: (superview?.safeAreaLayoutGuide.leftAnchor)!).isActive = true
        self.backgroundColor = .white
        self.layer.shadowColor = Colors.darkDarkGray.cgColor
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 50.0
        height = self.heightAnchor.constraint(equalToConstant: 465)
        height?.isActive = true
        setNoEdit()
    }
}

// MARK: scroll and keyboard
extension ProfileView {

}

// MARK: text fields
extension ProfileView {
    private func setFields() {
        [username, email].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
        }
        username.topAnchor.constraint(equalTo: ava.bottomAnchor, constant: 30).isActive = true
        email.topAnchor.constraint(equalTo: username.bottomAnchor, constant: 30).isActive = true
    }
}

// MARK: nav
extension ProfileView {
    private func setNavButtons() {
        guard let markSettings = UIImage(named: "settings") else { return }
        let settings = SubstrateButton(image: markSettings, side: 33, target: self, action: #selector(setEdit),
                                       substrateColor: Colors.lightBlue)
        addSubview(settings)
        settings.translatesAutoresizingMaskIntoConstraints = false
        settings.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        settings.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true

        guard let markLogout = UIImage(named: "logout") else { return }
        let substrateLogout = SubstrateButton(image: markLogout, side: 33, target: self, action: #selector(logout),
                                       substrateColor: Colors.darkGray)
        addSubview(substrateLogout)
        substrateLogout.translatesAutoresizingMaskIntoConstraints = false
        substrateLogout.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        substrateLogout.rightAnchor.constraint(
            equalTo: self.safeAreaLayoutGuide.rightAnchor,
            constant: -20
        ).isActive = true
    }

    @objc private func setNavEditButtons() {
        guard let markYes = UIImage(named: "yes") else { return }
        let yes = SubstrateButton(image: markYes, side: 33, target: self, action: #selector(save_settings),
                                  substrateColor: Colors.yellow)
        addSubview(yes)
        yes.translatesAutoresizingMaskIntoConstraints = false
        yes.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        yes.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true

        guard let markNo = UIImage(named: "close") else { return }
        let substrateNot = SubstrateButton(image: markNo, side: 33, target: self, action: #selector(no_settings),
                                 substrateColor: Colors.darkGray)
        addSubview(substrateNot)
        substrateNot.translatesAutoresizingMaskIntoConstraints = false
        substrateNot.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 7).isActive = true
        substrateNot.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20).isActive = true
    }
}

// MARK: ava
extension ProfileView {
    private func setAva() {
        addSubview(ava)
        ava.translatesAutoresizingMaskIntoConstraints = false
        ava.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        ava.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 33+30+7).isActive = true
        ava.widthAnchor.constraint(equalToConstant: 170).isActive = true
        ava.heightAnchor.constraint(equalToConstant: 170).isActive = true
        ava.contentMode = .scaleAspectFill
        ava.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                   .layerMinXMaxYCorner, .layerMinXMinYCorner]
        ava.layer.cornerRadius = 10
        ava.layer.masksToBounds = true

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let users = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            let usersO = users as? [User]
            let nowUser = usersO?.last
            ava.image = nowUser?.value(forKey: "ava") as? UIImage
//            CoreDataUser.getUser()
        } catch {
             print(error)
        }
        ava.isUserInteractionEnabled = false
    }
}

// MARK: passwords
extension ProfileView {
    private func setPassword() {
        [password, repeatPassword].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 300).isActive = true
            $0.isHidden = false
        }
        password.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 30).isActive = true
        repeatPassword.topAnchor.constraint(equalTo: password.bottomAnchor, constant: 30).isActive = true
    }
}

extension ProfileView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // MARK: save selected image to fileSystem using fileManager
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            // MARK: Get full path to selected image
            let fileManager = FileManager.default
            let imagesPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imagePath = imagesPath.appendingPathComponent("\(url.lastPathComponent)")
            print(imagePath)
            CoreDataUser.updateAvatar(imageURL: imagePath)
            CoreDataUser.getUser()
        }
        if let selected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            ava.image = selected
            // TODO: save in photo library if camera
        }
        delegateProfile?.dismissAlert()
    }

    @objc private func chooseAva() {
        let alert = UIAlertController(title: "Выберите изображение",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Галерея",
                                      style: .default,
                                      handler: { _ in { self.testAva.sourceType = .photoLibrary
                                                        self.delegateProfile?.chooseAvatar(picker: self.testAva) }() }
            ))
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            alert.addAction(UIAlertAction(title: "Камера",
                                          style: .default,
                                          handler: { _ in { self.testAva.sourceType = .camera
                                                            self.testAva.cameraCaptureMode = .photo
                                                            self.delegateProfile?.chooseAvatar(picker: self.testAva)
                                            }() }
            ))
        }
        alert.addAction(UIAlertAction(title: "Отменить", style: UIAlertAction.Style.cancel, handler: nil))
        delegateProfile?.showAlert(alert: alert)
    }
}

// MARK: bottom line
extension ProfileView {
    private func renderBottomLine() {
        addSubview(lineBottom)
        lineBottom.translatesAutoresizingMaskIntoConstraints = false
        lineBottom.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
        lineBottom.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -23).isActive = true
    }
}
