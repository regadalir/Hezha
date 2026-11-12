import SwiftUI

@main
struct HazhirKeyboardApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 18) {
                Text("کیبۆردی کوردی")
                    .font(.largeTitle.bold())
                Text("Settings › General › Keyboard › Keyboards › Add New Keyboard… › HazhirKeyboard")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                TextField("لێرە تاقی بکەرەوە…", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal)
                Text("© Hazhir Hezha")
                    .foregroundColor(.secondary)
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
}
