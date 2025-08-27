//
//  CashCatcherView.swift
//  DaFoVo1
//
//  Cash Catcher Mini-Game Interface
//

import SwiftUI

struct CashCatcherView: View {
    @StateObject private var viewModel = CashCatcherViewModel()
    @State private var screenSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Starry background
                StarryBackgroundView(stars: viewModel.stars)
                
                switch viewModel.gameState {
                case .menu:
                    MenuView(viewModel: viewModel)
                case .playing:
                    GamePlayView(viewModel: viewModel, screenSize: geometry.size)
                case .paused:
                    PausedView(viewModel: viewModel)
                case .gameOver:
                    GameOverView(viewModel: viewModel)
                }
            }
            .onAppear {
                screenSize = geometry.size
                viewModel.generateStars()
            }
            .onChange(of: geometry.size) { newSize in
                screenSize = newSize
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Starry Background
struct StarryBackgroundView: View {
    let stars: [Star]
    
    var body: some View {
        ZStack {
            // Deep space gradient
            LinearGradient(
                colors: [
                    Color.black,
                    Color.blue.opacity(0.3),
                    Color.purple.opacity(0.2),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Stars
            ForEach(stars) { star in
                Circle()
                    .fill(Color.white.opacity(star.brightness))
                    .frame(width: star.size, height: star.size)
                    .position(star.position)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true),
                        value: star.brightness
                    )
            }
        }
    }
}

// MARK: - Menu View
struct MenuView: View {
    @ObservedObject var viewModel: CashCatcherViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Game Title
            VStack(spacing: 10) {
                Text("💸")
                    .font(.system(size: 80))
                
                Text("Cash Catcher")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Catch falling money!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // High Score
            if viewModel.stats.highScore > 0 {
                VStack(spacing: 8) {
                    Text("High Score")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("$\(viewModel.stats.highScore)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.yellow)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Start Button
            Button(action: {
                viewModel.startGame()
            }) {
                Text("Start Game")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.yellow)
                    )
            }
            .padding(.horizontal, 40)
            
            // Instructions
            VStack(spacing: 8) {
                Text("How to Play:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Tap falling bills to catch them\nHigher denominations = more points!")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Gameplay View
struct GamePlayView: View {
    @ObservedObject var viewModel: CashCatcherViewModel
    let screenSize: CGSize
    
    var body: some View {
        ZStack {
            // Game Area
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            viewModel.catchBill(at: value.location)
                        }
                )
            
            // Falling Bills
            ForEach(viewModel.fallingBills) { bill in
                BillView(bill: bill)
                    .position(bill.position)
                    .animation(.none, value: bill.position)
            }
            
            // UI Overlay
            VStack {
                // Top HUD
                HStack {
                    // Score
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Score")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text(viewModel.formattedScore)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    // Time
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Time")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text(viewModel.formattedTime)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                        .blur(radius: 10)
                )
                
                Spacer()
                
                // Pause Button
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.pauseGame()
                    }) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                            )
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Bill View
struct BillView: View {
    let bill: FallingBill
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(bill.denomination.color)
                .frame(width: 60, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            Text(bill.denomination.displayText)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .rotationEffect(.degrees(bill.rotation))
        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Paused View
struct PausedView: View {
    @ObservedObject var viewModel: CashCatcherViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("⏸️")
                    .font(.system(size: 60))
                
                Text("Game Paused")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.resumeGame()
                    }) {
                        Text("Resume")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.green)
                            )
                    }
                    
                    Button(action: {
                        viewModel.returnToMenu()
                    }) {
                        Text("Main Menu")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    @ObservedObject var viewModel: CashCatcherViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🎯")
                    .font(.system(size: 80))
                
                Text("Game Over!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Stats
                VStack(spacing: 16) {
                    StatRow(title: "Final Score", value: viewModel.formattedScore, color: .yellow)
                    StatRow(title: "Bills Caught", value: "\(viewModel.stats.billsCaught)", color: .green)
                    StatRow(title: "Accuracy", value: viewModel.accuracyPercentage, color: .blue)
                    
                    if viewModel.stats.score == viewModel.stats.highScore && viewModel.stats.score > 0 {
                        Text("🏆 NEW HIGH SCORE! 🏆")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.yellow.opacity(0.2))
                            )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.startGame()
                    }) {
                        Text("Play Again")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.yellow)
                            )
                    }
                    
                    Button(action: {
                        viewModel.returnToMenu()
                    }) {
                        Text("Main Menu")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
    }
}

#Preview {
    CashCatcherView()
}
