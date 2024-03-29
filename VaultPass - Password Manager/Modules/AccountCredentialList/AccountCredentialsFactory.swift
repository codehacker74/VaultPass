//
//  AccountCredentialsFactory.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 6/6/23.
//

import UIKit

class AccountCredentialsFactory {
    
    func makeMediatingController(accountManager: AccountCredentialsManager) -> UIViewController {
        let controller = AccountCredentialsMediatingController()
        let navigation = UINavigationController(rootViewController: controller)
        let coordinator = makeCoordinator(accountManager: accountManager, navigation: navigation)
        controller.delegate = coordinator
        return navigation
    }
    
    func makeCoordinator(accountManager: AccountCredentialsManager, navigation: UINavigationController) -> AccountCredentialsDelegate {
        return AccountCredentialsCoordinator(accountManager: accountManager, navigation: navigation)
    }
}
