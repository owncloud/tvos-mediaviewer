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
						/*
						let bookmark = OCBookmark();
						bookmark.url = URL(string: "https://demo.owncloud.com")
						let connection = OCConnection(bookmark: bookmark)
						print("Contacting server…")
						connection.prepareForSetup(options: nil) { (issue, _, _, preferredAuthenticationMethods) in

						}*/

						let hudCompletion: (((() -> Void)?) -> Void) = { (completion) in
				OnMainThread {
					print("hud completion")
				}
			}

							//handleContinueURLProbe(hudCompletion: hudCompletion)
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

			print("--> \(options)")

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

func handleContinueURLProbe(hudCompletion: @escaping (((() -> Void)?) -> Void)) {

		   var username : NSString?, password: NSString?
		   var protocolWasPrepended : ObjCBool = false


		print("handleContinueURLProbe")
		   // Normalize URL
		   if let serverURL = NSURL(username: &username, password: &password, afterNormalizingURLString: serverurl, protocolWasPrepended: &protocolWasPrepended) as URL? {

			print(serverURL)
			   // Check for zero-length host name
			   if (serverURL.host == nil) || ((serverURL.host != nil) && (serverURL.host?.count==0)) {
				   // Missing hostname
				   /*let alertController = UIAlertController(title: "Missing hostname", message: "The entered URL does not include a hostname.", preferredStyle: .alert)

				   alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))

				   self.present(alertController, animated: true, completion: nil)
*/
				   return
			   }
			print("--> probe url")
			   // Probe URL
			   bookmark?.url = serverURL

			   if let connectionBookmark = bookmark {
				   let connection = OCConnection(bookmark: connectionBookmark)
				   let previousCertificate = bookmark?.certificate

			 print("--> prepareForSetup")

				   connection.prepareForSetup(options: nil) { (issue, _, _, preferredAuthenticationMethods) in
					   hudCompletion({
						print("--> prepareForSetup finishe")

						   let continueToNextStep : () -> Void = {
							   self.bookmark?.authenticationMethodIdentifier = preferredAuthenticationMethods?.first
							  /* self?.composeSectionsAndRows(animated: true) {
								   self?.updateInputFocus()
							   }
*/
							   if self.bookmark?.certificate == previousCertificate,
								  let authMethodIdentifier = self.bookmark?.authenticationMethodIdentifier,
								  OCAuthenticationMethod.isAuthenticationMethodTokenBased(authMethodIdentifier as OCAuthenticationMethodIdentifier) == true {

								  // self?.handleContinue()
							   }
						   }

						print("--> \(issue)")
						   if issue != nil {
						   } else {
							   continueToNextStep()
						   }
					   })
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

func OnMainThread(async: Bool = true, after: TimeInterval? = nil, inline: Bool = false, _ block: @escaping () -> Void) {
	if inline {
		if Thread.isMainThread {
			block()
			return
		}
	}

	if let after = after {
		DispatchQueue.main.asyncAfter(deadline: .now() + after, execute: block)
	} else {
		if async {
			DispatchQueue.main.async(execute: block)
		} else {
			DispatchQueue.main.sync(execute: block)
		}
	}
}

func OnBackgroundQueue(async: Bool = true, after: TimeInterval? = nil, _ block: @escaping () -> Void) {
	if let after = after {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + after, execute: block)
	} else {
		if async {
			DispatchQueue.global(qos: .background).async(execute: block)
		} else {
			DispatchQueue.global(qos: .background).sync(execute: block)
		}
	}
}

