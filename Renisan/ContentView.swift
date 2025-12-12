//
//  ContentView.swift
//  Renisan
//
//  Created by erhan gumus on 11/18/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // Brand colors
    let primaryColor = Color(red: 0.16, green: 0.50, blue: 0.45)
    let darkColor = Color(red: 0.10, green: 0.35, blue: 0.32)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [primaryColor, darkColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    // App Icon
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("Rênîşan")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Klavyeya Kurmancî ya Jîr")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                // Tab Selector
                HStack(spacing: 4) {
                    TabButton(title: "Taybetmendî", icon: "sparkles", isSelected: selectedTab == 0) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 }
                    }
                    TabButton(title: "Çawa Bikar Bînin", icon: "keyboard", isSelected: selectedTab == 1) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
                // Content
                TabView(selection: $selectedTab) {
                    FeaturesView(primaryColor: primaryColor)
                        .tag(0)
                    
                    SetupView(primaryColor: primaryColor)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.footnote)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? .white : .white.opacity(0.15))
            .foregroundColor(isSelected ? Color(red: 0.16, green: 0.50, blue: 0.45) : .white)
            .cornerRadius(20)
        }
    }
}

// MARK: - Features View (What makes this keyboard special)
struct FeaturesView: View {
    let primaryColor: Color
    @State private var animatePrediction = false
    @State private var animateAutocorrect = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Main Feature: Kurdish Characters
                FeatureSection(
                    icon: "character.textbox",
                    iconColor: .orange,
                    title: "Tîpên Kurdî",
                    subtitle: "Kurdish Characters"
                ) {
                    VStack(spacing: 12) {
                        Text("Hemû tîpên Kurmancî di nav de ne")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Kurdish character showcase
                        HStack(spacing: 8) {
                            ForEach(["Ê", "Î", "Û", "Ş", "Ç"], id: \.self) { char in
                                Text(char)
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .frame(width: 50, height: 50)
                                    .background(primaryColor.opacity(0.1))
                                    .foregroundColor(primaryColor)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Text("ê î û ş ç")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Main Feature: Word Prediction
                FeatureSection(
                    icon: "text.bubble.fill",
                    iconColor: .blue,
                    title: "Pêşbîniya Peyvan",
                    subtitle: "Smart Word Prediction"
                ) {
                    VStack(spacing: 16) {
                        Text("Bi modela N-gram, peyvên pêşniyar dide")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Prediction Demo
                        VStack(spacing: 8) {
                            HStack {
                                Text("Ez diçim")
                                    .font(.system(size: 18))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.secondary)
                                
                                Text("...")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Suggestion pills
                            HStack(spacing: 8) {
                                PredictionPill(word: "bazarê", isHighlighted: true)
                                PredictionPill(word: "malê", isHighlighted: false)
                                PredictionPill(word: "dibistanê", isHighlighted: false)
                            }
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                                .font(.caption)
                            Text("Ji 50,000+ hevokan hînbûyî")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                // Main Feature: Autocorrect
                FeatureSection(
                    icon: "checkmark.seal.fill",
                    iconColor: .green,
                    title: "Rastnivîsa Jîr",
                    subtitle: "Smart Autocorrect"
                ) {
                    VStack(spacing: 16) {
                        Text("Şaşiyên nivîsandinê otomatîk rast dike")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Autocorrect Demo
                        VStack(spacing: 12) {
                            // Before
                            HStack {
                                Text("pirtuk")
                                    .font(.system(size: 18))
                                    .strikethrough(true, color: .red)
                                    .foregroundColor(.red.opacity(0.7))
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.green)
                                
                                Text("pirtûk")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            
                            // Another example
                            HStack {
                                Text("xwendkra")
                                    .font(.system(size: 16))
                                    .strikethrough(true, color: .red)
                                    .foregroundColor(.red.opacity(0.7))
                                
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                
                                Text("xwendekar")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Technical explanation
                        HStack(spacing: 4) {
                            Image(systemName: "keyboard")
                                .font(.caption)
                            Text("Keyboard-aware: Tîpên nêzîk hev dizane")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                // Privacy Feature
                FeatureSection(
                    icon: "lock.shield.fill",
                    iconColor: .purple,
                    title: "Nepenî & Ewlehî",
                    subtitle: "Privacy & Security"
                ) {
                    VStack(spacing: 12) {
                        PrivacyRow(icon: "wifi.slash", text: "Bê înternetê dixebite")
                        PrivacyRow(icon: "icloud.slash", text: "Tu dane nayê şandin")
                        PrivacyRow(icon: "eye.slash", text: "Nivîsandina te nepenî ye")
                    }
                }
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}

// MARK: - Prediction Pill
struct PredictionPill: View {
    let word: String
    let isHighlighted: Bool
    
    var body: some View {
        Text(word)
            .font(.system(size: 14, weight: isHighlighted ? .semibold : .regular))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isHighlighted ? Color(red: 0.16, green: 0.50, blue: 0.45) : Color(.systemGray5))
            .foregroundColor(isHighlighted ? .white : .primary)
            .cornerRadius(16)
    }
}

// MARK: - Privacy Row
struct PrivacyRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.purple)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

// MARK: - Feature Section Card
struct FeatureSection<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.15))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Setup View
struct SetupView: View {
    let primaryColor: Color
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Setup Instructions Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "keyboard.fill")
                            .font(.title2)
                            .foregroundColor(primaryColor)
                        Text("Çawa Aktîv Bikin")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, 4)
                    
                    SetupStepView(
                        number: 1,
                        title: "Mîhengên Vekin",
                        subtitle: "Settings → General → Keyboard",
                        icon: "gearshape.fill",
                        primaryColor: primaryColor
                    )
                    
                    SetupStepView(
                        number: 2,
                        title: "Klavyeyan Hilbijêrin",
                        subtitle: "Keyboards → Add New Keyboard",
                        icon: "plus.rectangle.on.rectangle",
                        primaryColor: primaryColor
                    )
                    
                    SetupStepView(
                        number: 3,
                        title: "Rênîşan Hilbijêrin",
                        subtitle: "Di lîsteyê de \"Rênîşan\" bibînin",
                        icon: "checkmark.circle.fill",
                        primaryColor: primaryColor
                    )
                    
                    SetupStepView(
                        number: 4,
                        title: "Bikar Bînin!",
                        subtitle: "🌍 bikirtînin bo guherandinê",
                        icon: "globe",
                        primaryColor: primaryColor
                    )
                    
                    Button(action: openSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Mîhengan Veke")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Tips Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Serişteyên Bikêrhatî")
                            .font(.headline)
                    }
                    
                    TipRow(text: "🌍 Pêl bikin bo guherandina klavyeyê")
                    TipRow(text: "📝 Pêşniyaran bikirtînin bo zêdekirinê")
                    TipRow(text: "⌫ Dirêj pêl bikin bo jêbirina zû")
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                
                // Version info
                Text("Guhertoya 1.0")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 20)
                
                Spacer(minLength: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(red: 0.16, green: 0.50, blue: 0.45).opacity(0.2))
                .frame(width: 8, height: 8)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Setup Step View
struct SetupStepView: View {
    let number: Int
    let title: String
    let subtitle: String
    let icon: String
    let primaryColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(primaryColor.opacity(0.6))
        }
    }
}

#Preview {
    ContentView()
}
