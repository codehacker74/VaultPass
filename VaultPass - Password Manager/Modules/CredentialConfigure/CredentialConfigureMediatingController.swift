//
//  CredentialConfigureMediatingController.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/12/23.
//

import UIKit

protocol CredentialConfigureDelegate: PasswordSettingsDelegate {
    func credentialConfigureViewDidLoad(displayable: CredentialConfigureDisplayable)
    func credentialConfigureViewWillDisappear()
    func saveCredential(_ credential: AccountCredential, vc: CredentialConfigureMediatingController?)
    func generatePassword() -> String
    func deleteButtonPressed(vc: CredentialConfigureMediatingController?)
    func passwordTextFieldDidChange(_ displayable: CredentialConfigureDisplayable, text: String)
}

protocol CredentialConfigureDisplayable {
    func fillFields(with credential: AccountCredential)
    func hideDeleteButton()
    func changePasswordTextFieldBackground(with color: UIColor)
    func showPasswordSettings()
}

protocol CredentialProviderDelegate {
    func updateCredentials()
}

class CredentialConfigureMediatingController: UIViewController {
    
    @IBOutlet private(set) var titleField: UITextField!
    @IBOutlet private(set) var identifierField: UITextField!
    @IBOutlet private(set) var usernameField: UITextField!
    @IBOutlet private(set) var passwordField: UITextField!
    @IBOutlet private(set) var errorLabel: UILabel!
    @IBOutlet private(set) var passwordSettingsBtn: UIButton!
    @IBOutlet private(set) var generatePasswordBtn: UIButton!
    @IBOutlet private(set) var saveButton: UIButton!
    @IBOutlet private(set) var deleteBtn: UIButton!
    @IBOutlet private(set) var showPasswordBtn: UIButton!
    @IBOutlet private(set) var copyPasswordBtn: UIButton!
    @IBOutlet private(set) var padConstraints: [NSLayoutConstraint]! {
        didSet {
            PadConstraints.setLeadingTrailingConstraints(self.padConstraints)
        }
    }
    
    let delegate: CredentialConfigureDelegate?
    var copyToClipboardConfirmationView: CopyToClipboardConfirmationView?
    var passwordSettingsView: PasswordSettingsView?
    var shadowView: UIView?
    
    init(delegate: CredentialConfigureDelegate?) {
        self.delegate = delegate
        super.init(nibName: "CredentialConfigureMediatingController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.delegate = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.credentialConfigureViewDidLoad(displayable: self)
        self.setupTextFields()
        self.navigationItem.title = "Credential Configuration"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.credentialConfigureViewWillDisappear()
    }
    
    private func setupTextFields() {
        self.titleField.delegate = self
        self.identifierField.delegate = self
        self.usernameField.delegate = self
        self.passwordField.delegate = self
    }
    
    @IBAction func passwordSettingsBtnPressed(_ sender: UIButton) {
        self.showPasswordSettings()
    }
    
    @IBAction func generatePasswordBtnPressed(_ sender: UIButton) {
        guard let newPassword = self.delegate?.generatePassword(), !newPassword.isEmpty else {
            self.showError("Password failed to generate")
            return
        }
        self.hideErrorIfNeeded()
        self.setPasswordTextField(with: newPassword)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let title = self.titleField.text, !title.replacingOccurrences(of: " ", with: "").isEmpty else {
            self.showError("Title required")
            return
        }
        guard let username = self.usernameField.text, let password = self.passwordField.text, (!username.isEmpty && !password.isEmpty) else {
            self.showError("Username or password is required")
            return
        }
        var identifier: String = ""
        if let identifierText = identifierField.text {
            if identifierText.isEmpty {
                identifier = "\(title.replacingOccurrences(of: " ", with: "").lowercased())" + ".com"
            } else {
                identifier = identifierText
            }
        }
        
        let credential = AccountCredential(title: title, identifier: identifier, username: username, password: password)
        self.delegate?.saveCredential(credential, vc: self)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        self.delegate?.deleteButtonPressed(vc: self)
    }
    
    @IBAction func showPasswordPressed(_ sender: UIButton) {
        if self.passwordField.isSecureTextEntry {
            self.showPasswordBtn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            self.passwordField.isSecureTextEntry = false
        } else {
            self.showPasswordBtn.setImage(UIImage(systemName: "eye"), for: .normal)
            self.passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func copyPasswordPressed(_ sender: UIButton) {
        guard let password = self.passwordField.text, !password.isEmpty else {
            return
        }
        UIPasteboard.copyToClipboard(password)
        self.showCopyToClipboardView()
    }
    
    private func showError(_ error: String){
        self.errorLabel.text = error
        if self.errorLabel.isHidden {
            self.errorLabel.isHidden = false
        }
    }
    
    private func hideErrorIfNeeded() {
        if self.errorLabel.isHidden == false {
            self.errorLabel.isHidden = true
        }
    }
    
    func setPasswordTextField(with text: String) {
        self.passwordField.text = text
        self.delegate?.passwordTextFieldDidChange(self, text: text)
    }
}

extension CredentialConfigureMediatingController: CredentialConfigureDisplayable {
    func fillFields(with credential: AccountCredential) {
        self.titleField.text = credential.title
        self.identifierField.text = credential.identifier
        self.usernameField.text = credential.decryptedUsername
        self.setPasswordTextField(with: credential.decryptedPassword)
    }
    
    func hideDeleteButton() {
        self.deleteBtn.isHidden = true
    }
    
    func changePasswordTextFieldBackground(with color: UIColor) {
        self.passwordField.backgroundColor = color
    }
    
    func showPasswordSettings() {
        let newShadowView: UIView = UIView(frame: self.view.frame)
        newShadowView.backgroundColor = .label
        newShadowView.alpha = 0.4
        let settingsView: PasswordSettingsView = PasswordSettingsView.initFromNib()
        settingsView.setup(delegate: self.delegate, withCloseButton: true)
        settingsView.closeButton.addTarget(self, action: #selector(hidePasswordSettings(_:)), for: .touchUpInside)
        settingsView.layer.cornerRadius = 8
        self.view.addSubview(newShadowView)
        self.view.addSubview(settingsView)
        
        newShadowView.center = self.view.center
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingConstraint = settingsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16)
        let trailingConstraint = settingsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
        self.padConstraints = self.padConstraints + [leadingConstraint, trailingConstraint]
        
        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingConstraint,
            settingsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            settingsView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])
        
        self.passwordSettingsView = settingsView
        self.shadowView = newShadowView
    }
    
    @objc func hidePasswordSettings(_ sender: AnyObject) {
        self.passwordSettingsView?.removeFromSuperview()
        self.shadowView?.removeFromSuperview()
        
        self.passwordSettingsView = nil
        self.shadowView = nil
    }
}

extension CredentialConfigureMediatingController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hideErrorIfNeeded()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.passwordField {
            var text = (textField.text ?? "") + string
            if string.isEmpty && (range.length == textField.text?.count) {
                text = ""
            }
            self.delegate?.passwordTextFieldDidChange(self, text: text)
        }
        return true
    }
}

extension CredentialConfigureMediatingController: CopyToClipboardViewDelegate, CopyToClipboardDelegate {
    func showCopyToClipboardView() {
        if let _ = self.copyToClipboardConfirmationView {
            self.replaceCopyToClipboardView(self.view, clipboardView: self.copyToClipboardConfirmationView, delegate: self, completion: { newClipboardView in
                self.copyToClipboardConfirmationView = newClipboardView
            })
        } else {
            self.copyToClipboardConfirmationView = self.showCopyToClipboardView(view: self.view, delegate: self)
        }
    }
    
    func dismissClipboardView() {
        self.dismissCopyToClipboardView(self.view, self.copyToClipboardConfirmationView)
    }
}
