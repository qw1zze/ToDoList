//
//  TaskListCell.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import UIKit

class TaskListCell: UITableViewCell {
    
    static let identifier = "TaskListCell"
    
    var checkBoxTapped: ((Bool) -> Void)?
    
    private lazy var checkBox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(resource: .checkBox), for: .normal)
        button.setImage(UIImage(resource: .checkBoxFilled), for: .selected)
        button.addTarget(self, action: #selector(checkBoxDidTap), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        
        return stackView
    }()
    
    private var stackLeadingToCheckbox: NSLayoutConstraint?
    private var stackLeadingToLeft: NSLayoutConstraint?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: "WhiteTodo")
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "WhiteTodo")
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(named: "WhiteTodo")
        label.alpha = 0.5
        
        label.text = "02/10/24"
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        selectedTask(false)
    }
    
    private func setupUI() {
        backgroundColor = UIColor(named: "BlackTodo")
        contentView.backgroundColor = UIColor(named: "BlackTodo")
        
        contentView.addSubview(checkBox)
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkBox.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkBox.widthAnchor.constraint(equalToConstant: 24),
            checkBox.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        contentView.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackLeadingToCheckbox = mainStackView.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8)
        stackLeadingToLeft = mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        
        stackLeadingToCheckbox?.isActive = true
        NSLayoutConstraint.activate([
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    @objc private func checkBoxDidTap(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05) {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            sender.alpha = 0.8
        } completion: { [weak self] _ in
            sender.isSelected.toggle()
            self?.completeText(sender.isSelected)
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
                sender.alpha = 1.0
            } completion: { [weak self] _ in
                self?.checkBoxTapped?(sender.isSelected)
            }
        }
        
        
    }
    
    private func completeText(_ completed: Bool) {
        guard let text = titleLabel.text else { return }
        
        if completed {
            let attributes: [NSAttributedString.Key: Any] = [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            titleLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
            titleLabel.alpha = 0.5
            descriptionLabel.alpha = 0.5
        } else {
            titleLabel.attributedText = NSAttributedString(string: text, attributes: [:])
            titleLabel.alpha = 1
            descriptionLabel.alpha = 1
        }
    }
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        checkBox.isSelected = task.completed
        completeText(checkBox.isSelected)
        dateLabel.text = task.date?.toString() ?? Date.now.toString()
    }
    
    func selectedTask(_ selected: Bool) {
        checkBox.isHidden = selected
        contentView.backgroundColor = selected ? UIColor(named: "GrayTodo") : UIColor(named: "BlackTodo")
        self.backgroundColor = contentView.backgroundColor
        if selected {
            contentView.layer.cornerRadius = 12
            contentView.clipsToBounds = true
            layer.cornerRadius = 12
            clipsToBounds = true
            stackLeadingToCheckbox?.isActive = false
            stackLeadingToLeft?.isActive = true
        } else {
            contentView.layer.cornerRadius = 0
            contentView.clipsToBounds = false
            layer.cornerRadius = 0
            clipsToBounds = false
            stackLeadingToLeft?.isActive = false
            stackLeadingToCheckbox?.isActive = true
        }
        contentView.layoutSubviews()
    }
}
