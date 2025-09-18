//
//  TaskListBottomBarView.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import UIKit

final class TaskListBottomBarView: UIView {
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "WhiteTodo")
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    let createButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "NewTask")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "YellowTodo")
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "GrayTodo")
        
        addSubview(countLabel)
        addSubview(createButton)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 23),
            
            createButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            createButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            createButton.widthAnchor.constraint(equalToConstant: 68),
            createButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}


