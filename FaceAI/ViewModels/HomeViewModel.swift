import PhotosUI
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var selectedItem: PhotosPickerItem?
}
