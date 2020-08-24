//
//  RequestCell.swift
//  SafeMapp
//
//  Created by Aarón on 23/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {

    static let rowHeight: CGFloat = 180
    
    let buttonsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    let labelsContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        return stack
    }()
    
    var userImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "man")
        return image
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Nombre"
        return label
    }()
    
    let nameValueLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        return label
    }()
    
    let emailValueLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Fecha"
        return label
    }()
    
    let dateValueLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("ACEPTAR", for: .normal)
        button.backgroundColor = AppColors.greenColor
        return button
    }()
    
    let ignoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("IGNORAR", for: .normal)
        button.backgroundColor = AppColors.redColor
        return button
    }()
    
    var request: Request! {
        didSet {
            nameValueLabel.text = request.userName
            emailValueLabel.text = request.email
            
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.locale = Locale(identifier: NSLocalizedString("localeCode", comment: ""))
            dateFormatter.timeZone = TimeZone(identifier: NSLocalizedString("localeCode", comment: "")) //TODO: Get current time zone, do not user from localized
            dateFormatter.dateFormat = NSLocalizedString("dateFormat", comment: "")
            
            let readableDate: String = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(request!.timestamp / 1000)))
            
            dateValueLabel.text = "\(readableDate)"
            
            if request.image != "none" {
                let url = URL(string: request.image)
                
                URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil { return }
                    
                    DispatchQueue.main.async { self.userImage.image = UIImage(data: data!) }
                }.resume()
            }
        }
    }
    
    var callback: ((_ action: Bool) -> Void)?
    
    func setupData(request: Request) {
        self.request = request
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addViews()
        self.setupConstraints()
        self.setupEvents()
    }
    
    private func addViews() {
        addSubview(userImage)
        
        [
            nameValueLabel,
            emailValueLabel,
            dateValueLabel
        ].forEach { (label) in
            label.font = .systemFont(ofSize: 12)
            label.textAlignment = .left
        }
        
        [
            nameLabel,
            emailLabel,
            dateLabel
        ].forEach { (label) in
            label.font = .boldSystemFont(ofSize: 12)
            label.textAlignment = .left
        }
        
        labelsContainer.addArrangedSubview(nameLabel)
        labelsContainer.addArrangedSubview(nameValueLabel)
        labelsContainer.addArrangedSubview(emailLabel)
        labelsContainer.addArrangedSubview(emailValueLabel)
        labelsContainer.addArrangedSubview(dateLabel)
        labelsContainer.addArrangedSubview(dateValueLabel)
        
        addSubview(labelsContainer)
        
        [
            acceptButton,
            ignoreButton
        ].forEach { (button) in
            button.layer.cornerRadius = 15
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        }
        
        buttonsContainer.addArrangedSubview(acceptButton)
        buttonsContainer.addArrangedSubview(ignoreButton)
        
        addSubview(buttonsContainer)
    }
    
    private func setupConstraints() {
        [
            userImage,
            labelsContainer,
            buttonsContainer
        ].forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        userImage.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        userImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        userImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        userImage.layer.cornerRadius = 50
        userImage.layer.masksToBounds = true
        
        labelsContainer.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        labelsContainer.bottomAnchor.constraint(equalTo: buttonsContainer.topAnchor, constant: -10).isActive = true
        labelsContainer.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: 10).isActive = true
        labelsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
        buttonsContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        buttonsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        buttonsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        buttonsContainer.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    private func setupEvents() {
        acceptButton.isUserInteractionEnabled = true
        ignoreButton.isUserInteractionEnabled = true
        
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        ignoreButton.addTarget(self, action: #selector(ignoreButtonTapped), for: .touchUpInside)
    }
    
    @objc private func acceptButtonTapped() {
        callback?(true)
    }
    
    @objc private func ignoreButtonTapped() {
        callback?(false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
