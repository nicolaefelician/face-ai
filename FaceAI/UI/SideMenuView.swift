import SwiftUI

private struct SideMenuItem: View {
    let label: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 26, height: 26)
                Text(label)
                    .font(.custom(Fonts.shared.interSemibold, size: 18))
            }
            .foregroundStyle(.black.opacity(0.85))
        }
    }
}

struct SideMenuView: View {
    @ObservedObject private var globalState = GlobalState.shared
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Credits Left")
                        .font(.custom(Fonts.shared.interSemibold, size: 14))
                        .foregroundStyle(.gray)
                    
                    Text("\(globalState.credits)")
                        .font(.custom(Fonts.shared.instrumentSansSemibold, size: 28))
                        .foregroundStyle(Colors.shared.primaryColor)
                }
                .padding(.top, 30)
                
                Button(action: {
                    globalState.navigationPath.append(.prompts(category: nil))
                }) {
                    Text("All Prompts")
                        .font(.custom(Fonts.shared.instrumentSansSemibold, size: 24))
                        .foregroundStyle(.black)
                        .padding(.top, 15)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(PresetCategory.allCases, id: \.self) { category in
                        Button(action: {
                            globalState.navigationPath.append(.prompts(category: category))
                        }) {
                            Text(category.rawValue)
                                .font(.custom(Fonts.shared.interSemibold, size: 18))
                                .foregroundStyle(.black.opacity(0.85))
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 18) {
                    SideMenuItem(label: "Saved Images", icon: "bookmark", action: {
                        globalState.navigationPath.append(.saved)
                    })
                    SideMenuItem(label: "History", icon: "clock", action: {
                        globalState.navigationPath.append(.history)
                    })
                    SideMenuItem(label: "Settings", icon: "gearshape", action: {
                        globalState.navigationPath.append(.settings)
                    })
                    SideMenuItem(label: "Report issue", icon: "exclamationmark.circle", action: {
                        let email = "esmondandersonhaldegallagher@gmail.com"
                        let subject = "Support Request"
                        let body = "Hi, I need help with... (Face AI 1.0.0)"
                        let mailtoURL = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                        
                        if let url = URL(string: mailtoURL) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                print("Mail app is not available")
                            }
                        }
                    })
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .frame(width: 250)
        .animation(.easeInOut(duration: 0.25), value: globalState.showMenu)
    }
}
