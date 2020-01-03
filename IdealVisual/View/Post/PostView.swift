//
//  PhotoView.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.10.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

enum BlockPostType {
    case datePicker
    case textView
}

final class PostView: UIViewController {
    private var viewModel: PostViewModelProtocol?
    var publication: Post?
    let photo = UIImageView()
    var scroll = UIScrollView()
    let margin: CGFloat = 30.0
    var date: BlockPost? = nil, post: BlockPost? = nil, place: BlockPost? = nil

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.viewModel = PostViewModel()
        setInteraction()
        setupNavItems()
        setBlocks()
    }

    private func setInteraction() {
        let swipeBack = UISwipeGestureRecognizer(target: self, action: #selector(back))
        swipeBack.direction = .right
        view.addGestureRecognizer(swipeBack)

        view.addSubview(scroll)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scroll.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scroll.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    }

    private func setupNavItems() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .none

        navigationItem.setHidesBackButton(true, animated: false)
        guard let buttonBack = UIImage(named: "previous_gray")?.withRenderingMode(.alwaysOriginal) else { return }
        let myBackButton = SubstrateButton(image: buttonBack, side: 35, target: self, action: #selector(back),
                                           substrateColor: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: myBackButton)

        setupPhoto()
    }

    private func setupPhoto() {
        let marginTop = (navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height

        scroll.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        photo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        photo.heightAnchor.constraint(equalToConstant: view.bounds.width).isActive = true
        photo.topAnchor.constraint(equalTo: scroll.topAnchor, constant: -marginTop).isActive = true
        photo.contentMode = .scaleAspectFit

        guard let markEdit = UIImage(named: "edit")?.withRenderingMode(.alwaysOriginal) else { return }
        let edit = SubstrateButton(image: markEdit, side: 35, target: self, action: #selector(editBlock),
                                   substrateColor: Colors.darkGray)
        view.addSubview(edit)
        edit.translatesAutoresizingMaskIntoConstraints = false
        edit.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: -45).isActive = true
        edit.rightAnchor.constraint(equalTo: photo.rightAnchor, constant: -10).isActive = true
    }

    private func setBlocks() {
        let blockPostType = BlockPostType.self

        var dcp: DatePickerComponent?
        if let date = publication?.date {
            if date != Date() {
                dcp = DatePickerComponent()
                dcp?.date = date
            }
        }
        date = BlockPost(
            textValue: nil,
            iconImage: UIImage(named: "date")!, buttonIext: "Добавить дату", datePicker: dcp, view: scroll,
            blockPostType: blockPostType.datePicker, delegatePost: self
        )
        guard let date = date else { return }

        place = BlockPost(
            textValue: publication?.place,
            iconImage: UIImage(named: "map")!, buttonIext: "Добавить место", datePicker: nil, view: scroll,
            blockPostType: blockPostType.textView, delegatePost: self
        )
        guard let place = place else { return }

        post = BlockPost(
            textValue: publication?.text,
            iconImage: UIImage(named: "post")!, buttonIext: "Добавить пост", datePicker: nil, view: scroll,
            blockPostType: blockPostType.textView, delegatePost: self
        )
        guard let post = post else { return }

        var prev = photo as UIView
        for value in [BlockPost](arrayLiteral: date, place, post) {
            value.translatesAutoresizingMaskIntoConstraints = false
            value.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
            value.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
            value.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: 20).isActive = true
            value.heightAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true // magic value

            prev = value
        }
        // Allows scroll view to resize dynamically
        prev.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -margin).isActive = true
    }

    @objc
    private func back() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func editBlock() {
        self.date?.setEditingBlock()
        self.post?.setEditingBlock()
        self.place?.setEditingBlock()
    }

    private func procError(error: ErrorViewModel?) {
        if let error = error {
            switch error {
            case ErrorsUserViewModel.noData:
                // TODO: ui
                break
            default:
                print("undefined error: \(error)"); return
            }
        }
    }
}

extension PostView: BlockProtocol {
    func updateBlock(from: BlockPost) {
        guard let publication = publication else { return }
        switch from {
        case self.post:
            viewModel?.update(post: publication, date: nil, place: nil, text: post?.textView?.text,
                             completion: { (error) in
                                DispatchQueue.main.async {
                                    self.procError(error: error)
                                }
            })
        case self.place:
            viewModel?.update(post: publication, date: nil, place: place?.textView?.text, text: nil,
                             completion: { (error) in
                                DispatchQueue.main.async {
                                    self.procError(error: error)
                                }
                            })
        case self.date:
            viewModel?.update(post: publication, date: date?.datePicker?.date, place: nil, text: nil,
                             completion: { (error) in
                                DispatchQueue.main.async {
                                    self.procError(error: error)
                                }
                            })
        default: break
        }
    }
}
