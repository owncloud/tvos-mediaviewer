//
//  MediaGridView.swift
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

struct MediaGridView : View {

	var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 4)
	private var gridItemLayout = [GridItem(.adaptive(minimum: 100))]

	var images : [ImageItem] = [ImageItem(name: "Paris"), ImageItem(name: "San Francisco"), ImageItem(name: "Squirrel")]

	var body: some View {

		ScrollView {
			LazyVGrid(columns: columns, spacing: 10) {
				ForEach(self.images, id: \.self) { imageItem in
					NavigationLink(destination: ImageDetailView(currentItem: imageItem, items: images)) {
						imageItem.image.resizable()
							.scaledToFit()
							.aspectRatio(contentMode: .fit)
						//.frame(width: 300.0, height:300)
					}
				}
			}.font(.largeTitle)
		}
	}
}
