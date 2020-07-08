//
//  AccountSettings.swift
//  ownCloud Media
//
//  Created by Matthias Hühne on 06.07.20.
//  Copyright © 2020 Matthias Hühne. All rights reserved.
//

/*
 * Copyright (C) 2020, ownCloud GmbH.
 *
 * This code is covered by the GNU Public License Version 3.
 *
 * For distribution utilizing Apple mechanisms please see https://owncloud.org/contribute/iOS-license-exception/
 * You should have received a copy of this license along with this program. If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>.
 *
 */

import SwiftUI
import ownCloudSDK

struct AccountSettingsView : View {

	@State private var serverurl: String = "https://demo.owncloud.com"
	@State private var username: String = "demo"
	@State private var password: String = "demo"
	var bookmark : OCBookmark?

	init() {
		bookmark = OCBookmark()
	}
	
	var body: some View {

		NavigationView {

			VStack {
				Form {
					Section {
						TextField("Server URL", text: $serverurl)
							.keyboardType(.URL)
						TextField("User Name", text: $username)
						SecureField("User Password", text: $password)
					}
				}

				Button(
					action: {
						let hudCompletion: (((() -> Void)?) -> Void) = { (completion) in
						}
						handleContinueAuthentication(hudCompletion: hudCompletion)
					},
					label: {
						Text("Save")
					}
				).buttonStyle(BorderedButtonStyle())
			}
		}.navigationTitle("Account Settings")
	}

	func handleContinueAuthentication(hudCompletion: @escaping (((() -> Void)?) -> Void)) {

		var username : NSString?, password: NSString?
		var protocolWasPrepended : ObjCBool = false

		if let serverURL = NSURL(username: &username, password: &password, afterNormalizingURLString: serverurl, protocolWasPrepended: &protocolWasPrepended) as URL? {

			bookmark?.url = serverURL
		}
		bookmark?.authenticationMethodIdentifier = .basicAuth

		if let connectionBookmark = bookmark {
			var options : [OCAuthenticationMethodKey : Any] = [:]

			let connection = OCConnection(bookmark: connectionBookmark)

			if let authMethodIdentifier = bookmark?.authenticationMethodIdentifier {
				if OCAuthenticationMethod.isAuthenticationMethodPassphraseBased(authMethodIdentifier as OCAuthenticationMethodIdentifier) {
					options[.usernameKey] = username
					options[.passphraseKey] = password
				}
			}

			options[.presentingViewControllerKey] = self

			guard let bookmarkAuthenticationMethodIdentifier = bookmark?.authenticationMethodIdentifier else { return }

			connection.generateAuthenticationData(withMethod: bookmarkAuthenticationMethodIdentifier, options: options) { (error, authMethodIdentifier, authMethodData) in
				if error == nil {
					self.bookmark?.authenticationMethodIdentifier = authMethodIdentifier
					self.bookmark?.authenticationData = authMethodData

				} else {
					print("--> issue \(error)")
				}
			}
		}
	}
}

public extension OCAuthenticationMethod {

	static func authenticationMethodTypeForIdentifier(_ authenticationMethodIdentifier: OCAuthenticationMethodIdentifier) -> OCAuthenticationMethodType? {
		if let authenticationMethodClass = OCAuthenticationMethod.registeredAuthenticationMethod(forIdentifier: authenticationMethodIdentifier) {
			return authenticationMethodClass.type
		}

		return nil
	}

	static func isAuthenticationMethodPassphraseBased(_ authenticationMethodIdentifier: OCAuthenticationMethodIdentifier) -> Bool {
		return authenticationMethodTypeForIdentifier(authenticationMethodIdentifier) == OCAuthenticationMethodType.passphrase
	}

	static func isAuthenticationMethodTokenBased(_ authenticationMethodIdentifier: OCAuthenticationMethodIdentifier) -> Bool {
		return authenticationMethodTypeForIdentifier(authenticationMethodIdentifier) == OCAuthenticationMethodType.token
	}

}
