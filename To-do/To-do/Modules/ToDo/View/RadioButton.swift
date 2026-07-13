//
//  RadioButton.swift
//  To-do
//
//  Created by Кирилл Зезюков on 02.09.2024.
//
import UIKit

final class RadioButton: UIButton {
    override var isSelected: Bool {
        didSet {
            body.layer.borderColor = isSelected
            ? UIColor.yellow.cgColor
            : UIColor.radioButtonColorUnselected.cgColor
            
            let color: UIColor = isSelected ? .yellow : .radioButtonColorUnselected
            let image = UIImage(systemName: "checkmark")?.withTintColor(color, renderingMode: .alwaysOriginal)
            checkmarkView.image = image
            
            checkmarkView.alpha = isSelected ? 1 : 0
        }
    }
    
    private lazy var body: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = Constants.radioButtonCornerRadius
        view.layer.borderWidth = Constants.radioButtonBorderWidth
        view.layer.borderColor = UIColor.white.cgColor
        
        return view
    }()
    
    private lazy var checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        isUserInteractionEnabled = true
        body.addSubview(checkmarkView)
        addSubview(body)
        
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: topAnchor),
            body.leadingAnchor.constraint(equalTo: leadingAnchor),
            body.trailingAnchor.constraint(equalTo: trailingAnchor),
            body.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            checkmarkView.topAnchor.constraint(equalTo: body.topAnchor, constant: Constants.radioButtonImageTop),
            checkmarkView.trailingAnchor.constraint(equalTo: body.trailingAnchor, constant: Constants.radioButtonImageTrailing),
            checkmarkView.leadingAnchor.constraint(equalTo: body.leadingAnchor, constant: Constants.radioButtonImageLeading),
            checkmarkView.bottomAnchor.constraint(equalTo: body.bottomAnchor, constant: Constants.radioButtonImageBottom)
        ])
    }
}
