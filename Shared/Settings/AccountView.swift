//
//  AccountView.swift
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

struct AccountView : View {

	var body: some View {
		List {
			NavigationLink(destination: AccountSettingsView()) {
				Text("Account Settings")
			}
		}
	}
}
