//
//  ToDoTableViewCell.swift
//  To-do
//
//  Created by Кирилл Зезюков on 29.08.2024.
//

import UIKit

protocol ToDoTableCellDelegate: AnyObject {
    func didSelect(todo: ToDoEntity)
    func update(todo: ToDoEntity)
    func delete(todo: ToDoEntity)
    func share(todo: ToDoEntity)
}

final class ToDoTableViewCell: UITableViewCell {
    static let identifier = "ToDoTableViewCell"
    weak var delegate: ToDoTableCellDelegate?
    var todo: ToDoEntity?
    
    private lazy var todoTitleView: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var todoDescriptionView: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dateOfCreation: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [todoDescriptionView, dateOfCreation])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var radioButton: UIButton = {
        let radioButton = RadioButton()
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.isUserInteractionEnabled = true
        radioButton.backgroundColor = .clear
        radioButton.addTarget(self, action: #selector(radioButtonDidTouched), for: .touchUpInside)
        return radioButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        setUpUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        radioButton.isSelected = false
        todoTitleView.attributedText = nil
        todoTitleView.text = nil
        todoTitleView.textColor = .white
        todoDescriptionView.text = nil
        dateOfCreation.text = nil
        todo = nil
    }

    @objc private func radioButtonDidTouched() {
        guard let todo = todo else { return }
        delegate?.didSelect(todo: todo)
    }
    
    private func setUpUI() {
        contentView.isUserInteractionEnabled = true
        
        contentView.addSubview(radioButton)
        contentView.addSubview(todoTitleView)
        contentView.addSubview(detailsStack)
        contentView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            radioButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            radioButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.radioButtonLeadingPadding),
            radioButton.widthAnchor.constraint(equalToConstant: Constants.radioButtonSize),
            radioButton.heightAnchor.constraint(equalToConstant: Constants.radioButtonSize),
            
            todoTitleView.centerYAnchor.constraint(equalTo: radioButton.centerYAnchor),
            todoTitleView.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: Constants.todoTextViewLeadingPadding),
            todoTitleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.todoTextViewTrailingPadding),
            
            detailsStack.topAnchor.constraint(equalTo: todoTitleView.bottomAnchor, constant: 6),
            detailsStack.leadingAnchor.constraint(equalTo: todoTitleView.leadingAnchor),
            detailsStack.trailingAnchor.constraint(equalTo: todoTitleView.trailingAnchor),
            detailsStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func configure(with todo: ToDoEntity) {
        self.todo = todo
        
        todoTitleView.attributedText = nil
        todoTitleView.text = todo.todo
        todoTitleView.textColor = .white
        
        todoDescriptionView.text = todo.description
        dateOfCreation.text = todo.date.toString()
        
        configCompletedState(todo.completed)
    }
    
    func configCompletedState(_ isCompleted: Bool) {
        radioButton.isSelected = isCompleted
        
        let baseText = todo?.todo ?? todoTitleView.text ?? ""
        
        if isCompleted {
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
            todoTitleView.attributedText = NSAttributedString(string: baseText, attributes: attributes)
        } else {
            todoTitleView.attributedText = nil
            todoTitleView.text = baseText
            todoTitleView.textColor = .white
        }
    }
}

extension ToDoTableViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self, self.todo != nil else { return UIMenu() }
            
            let editAction = UIAction(
                title: .update,
                image: UIImage(systemName: "pencil")
            ) { _ in
                guard let todo = self.todo else { return }
                self.delegate?.update(todo: todo)
            }
            
            let shareAction = UIAction(
                title: .share,
                image: UIImage(systemName: "square.and.arrow.up")
            ) { _ in
                guard let todo = self.todo else { return }
                self.delegate?.share(todo: todo)
            }
            
            let deleteAction = UIAction(
                title: .delete,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                guard let todo = self.todo else { return }
                self.delegate?.delete(todo: todo)
            }
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
}
