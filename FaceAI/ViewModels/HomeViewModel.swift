import PhotosUI
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem?
}
