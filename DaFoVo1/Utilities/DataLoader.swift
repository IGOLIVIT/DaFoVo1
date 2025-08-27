//
//  DataLoader.swift
//  DaFoVo1
//
//  Galaxy Finance Quest Data Management
//

import Foundation

class DataLoader: ObservableObject {
    static let shared = DataLoader()
    
    private init() {}
    
    // MARK: - User Progress Storage
    @Published var userProgress: UserProgress = UserProgress()
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "GalaxyFinanceQuest_UserProgress"
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(userProgress) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
    
    func loadProgress() {
        if let data = userDefaults.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            userProgress = decoded
        }
    }
    
    func clearProgress() {
        userProgress = UserProgress()
        userDefaults.removeObject(forKey: progressKey)
    }
    
    // MARK: - Mission Data
    func loadMissions() -> [Mission] {
        return [
            Mission(
                id: "basic_budget",
                title: "Planetary Budget Basics",
                description: "Learn to allocate resources for your new colony",
                difficulty: .beginner,
                rewards: 100,
                educationalContent: "Budgeting is the foundation of financial success. Allocate 50% for essentials, 30% for wants, and 20% for savings.",
                challengeType: .budgeting,
                isCompleted: false
            ),
            Mission(
                id: "compound_growth",
                title: "Stellar Investment Growth",
                description: "Discover the power of compound interest in space trading",
                difficulty: .intermediate,
                rewards: 250,
                educationalContent: "Compound interest is when you earn interest on both your original investment and previously earned interest. Time is your greatest ally.",
                challengeType: .investing,
                isCompleted: false
            ),
            Mission(
                id: "risk_management",
                title: "Asteroid Mining Risks",
                description: "Learn to balance risk and reward in volatile markets",
                difficulty: .advanced,
                rewards: 500,
                educationalContent: "Diversification reduces risk. Never put all your resources in one asteroid field.",
                challengeType: .riskManagement,
                isCompleted: false
            ),
            Mission(
                id: "emergency_fund",
                title: "Emergency Fuel Reserves",
                description: "Build an emergency fund for unexpected space travel",
                difficulty: .beginner,
                rewards: 150,
                educationalContent: "An emergency fund should cover 3-6 months of expenses. It's your financial safety net.",
                challengeType: .saving,
                isCompleted: false
            ),
            Mission(
                id: "debt_management",
                title: "Galactic Debt Elimination",
                description: "Strategies to eliminate high-interest space loans",
                difficulty: .intermediate,
                rewards: 300,
                educationalContent: "Pay off high-interest debt first. Use the debt avalanche method to save on interest payments.",
                challengeType: .debtManagement,
                isCompleted: false
            ),
            
            // MARK: - Advanced Budgeting Missions
            Mission(
                id: "zero_based_budget",
                title: "Zero-Based Colony Planning",
                description: "Master the zero-based budgeting technique for maximum efficiency",
                difficulty: .intermediate,
                rewards: 200,
                educationalContent: "Zero-based budgeting means every credit has a purpose. Income minus expenses should equal zero.",
                challengeType: .budgeting,
                isCompleted: false
            ),
            Mission(
                id: "seasonal_budget",
                title: "Seasonal Resource Management",
                description: "Plan for seasonal variations in colony income and expenses",
                difficulty: .advanced,
                rewards: 400,
                educationalContent: "Seasonal budgeting helps you prepare for predictable income fluctuations throughout the year.",
                challengeType: .budgeting,
                isCompleted: false
            ),
            Mission(
                id: "family_budget",
                title: "Multi-Colony Budget Coordination",
                description: "Manage budgets across multiple connected colonies",
                difficulty: .expert,
                rewards: 600,
                educationalContent: "Coordinating multiple budgets requires clear communication and shared financial goals.",
                challengeType: .budgeting,
                isCompleted: false
            ),
            
            // MARK: - Investment Missions
            Mission(
                id: "stock_basics",
                title: "Galactic Stock Exchange Basics",
                description: "Learn the fundamentals of space stock investing",
                difficulty: .beginner,
                rewards: 120,
                educationalContent: "Stocks represent ownership in companies. Research before investing and think long-term.",
                challengeType: .investing,
                isCompleted: false
            ),
            Mission(
                id: "etf_investing",
                title: "Diversified Space Funds",
                description: "Understand ETFs and mutual funds for diversified investing",
                difficulty: .intermediate,
                rewards: 280,
                educationalContent: "ETFs and mutual funds offer instant diversification and professional management.",
                challengeType: .investing,
                isCompleted: false
            ),
            Mission(
                id: "retirement_planning",
                title: "Galactic Retirement Planning",
                description: "Plan for your golden years in the outer rim",
                difficulty: .advanced,
                rewards: 450,
                educationalContent: "Start retirement planning early. Use tax-advantaged accounts and automate contributions.",
                challengeType: .investing,
                isCompleted: false
            ),
            Mission(
                id: "crypto_basics",
                title: "Digital Currency Mining",
                description: "Explore cryptocurrency and blockchain technology",
                difficulty: .expert,
                rewards: 550,
                educationalContent: "Cryptocurrency is volatile and speculative. Only invest what you can afford to lose.",
                challengeType: .investing,
                isCompleted: false
            ),
            
            // MARK: - Saving Missions
            Mission(
                id: "automated_savings",
                title: "Automated Resource Collection",
                description: "Set up automatic savings systems for your colony",
                difficulty: .beginner,
                rewards: 130,
                educationalContent: "Automate your savings to pay yourself first. Set up automatic transfers to savings accounts.",
                challengeType: .saving,
                isCompleted: false
            ),
            Mission(
                id: "high_yield_savings",
                title: "High-Yield Energy Storage",
                description: "Maximize returns on your emergency fund",
                difficulty: .intermediate,
                rewards: 220,
                educationalContent: "High-yield savings accounts offer better interest rates while keeping your money accessible.",
                challengeType: .saving,
                isCompleted: false
            ),
            Mission(
                id: "goal_based_saving",
                title: "Mission-Specific Savings",
                description: "Save for specific colony expansion goals",
                difficulty: .intermediate,
                rewards: 250,
                educationalContent: "Set specific savings goals with deadlines. Break large goals into smaller, manageable targets.",
                challengeType: .saving,
                isCompleted: false
            ),
            
            // MARK: - Debt Management Missions
            Mission(
                id: "debt_snowball",
                title: "Debt Snowball Strategy",
                description: "Use psychological momentum to eliminate small debts first",
                difficulty: .beginner,
                rewards: 180,
                educationalContent: "The debt snowball method builds momentum by paying off smallest debts first.",
                challengeType: .debtManagement,
                isCompleted: false
            ),
            Mission(
                id: "debt_consolidation",
                title: "Loan Consolidation Protocol",
                description: "Combine multiple debts into a single payment",
                difficulty: .intermediate,
                rewards: 320,
                educationalContent: "Debt consolidation can simplify payments and potentially reduce interest rates.",
                challengeType: .debtManagement,
                isCompleted: false
            ),
            Mission(
                id: "credit_score",
                title: "Galactic Credit Rating",
                description: "Understand and improve your credit score",
                difficulty: .advanced,
                rewards: 380,
                educationalContent: "Your credit score affects loan rates. Pay on time, keep balances low, and monitor regularly.",
                challengeType: .debtManagement,
                isCompleted: false
            ),
            
            // MARK: - Risk Management Missions
            Mission(
                id: "insurance_basics",
                title: "Colony Protection Insurance",
                description: "Protect your assets with proper insurance coverage",
                difficulty: .beginner,
                rewards: 160,
                educationalContent: "Insurance protects against financial catastrophe. Get adequate coverage for health, property, and life.",
                challengeType: .riskManagement,
                isCompleted: false
            ),
            Mission(
                id: "portfolio_diversification",
                title: "Multi-Sector Investment Strategy",
                description: "Spread investments across different sectors and asset classes",
                difficulty: .intermediate,
                rewards: 350,
                educationalContent: "Diversification reduces risk by spreading investments across different assets and sectors.",
                challengeType: .riskManagement,
                isCompleted: false
            ),
            Mission(
                id: "market_volatility",
                title: "Surviving Market Storms",
                description: "Navigate through economic downturns and market crashes",
                difficulty: .expert,
                rewards: 650,
                educationalContent: "Market volatility is normal. Stay calm, stick to your plan, and consider it a buying opportunity.",
                challengeType: .riskManagement,
                isCompleted: false
            ),
            
            // MARK: - Emergency Planning Missions
            Mission(
                id: "disaster_recovery",
                title: "Colony Disaster Recovery Plan",
                description: "Prepare financially for natural disasters and emergencies",
                difficulty: .intermediate,
                rewards: 290,
                educationalContent: "Emergency planning includes insurance, emergency funds, and important document storage.",
                challengeType: .emergencyPlanning,
                isCompleted: false
            ),
            Mission(
                id: "estate_planning",
                title: "Legacy Planning Protocol",
                description: "Plan for the transfer of wealth to future generations",
                difficulty: .advanced,
                rewards: 480,
                educationalContent: "Estate planning ensures your assets are distributed according to your wishes. Include wills and trusts.",
                challengeType: .emergencyPlanning,
                isCompleted: false
            ),
            Mission(
                id: "business_continuity",
                title: "Colony Business Continuity",
                description: "Ensure your colony's operations can survive disruptions",
                difficulty: .expert,
                rewards: 580,
                educationalContent: "Business continuity planning protects against operational and financial disruptions.",
                challengeType: .emergencyPlanning,
                isCompleted: false
            ),
            
            // MARK: - Advanced Financial Concepts
            Mission(
                id: "tax_optimization",
                title: "Galactic Tax Optimization",
                description: "Minimize tax burden through legal strategies",
                difficulty: .advanced,
                rewards: 420,
                educationalContent: "Tax optimization involves using legal strategies to minimize tax liability while maximizing wealth.",
                challengeType: .investing,
                isCompleted: false
            ),
            Mission(
                id: "real_estate",
                title: "Planetary Real Estate Investment",
                description: "Explore real estate as an investment vehicle",
                difficulty: .expert,
                rewards: 700,
                educationalContent: "Real estate can provide income and appreciation. Consider location, cash flow, and market trends.",
                challengeType: .investing,
                isCompleted: false
            ),
            Mission(
                id: "financial_independence",
                title: "Financial Independence Mission",
                description: "Achieve complete financial freedom",
                difficulty: .expert,
                rewards: 1000,
                educationalContent: "Financial independence means your investments generate enough income to cover all expenses.",
                challengeType: .investing,
                isCompleted: false
            )
        ]
    }
    
    // MARK: - Achievement Data
    func loadAchievements() -> [Achievement] {
        return [
            Achievement(
                id: "first_mission",
                title: "Space Cadet",
                description: "Complete your first financial mission",
                icon: "star.fill",
                isUnlocked: false,
                category: .missions,
                rarity: .common
            ),
            Achievement(
                id: "budget_master",
                title: "Budget Commander",
                description: "Complete 2 budgeting missions",
                icon: "chart.pie.fill",
                isUnlocked: false,
                category: .learning,
                rarity: .rare
            ),
            Achievement(
                id: "investment_guru",
                title: "Investment Admiral",
                description: "Master investment concepts",
                icon: "chart.line.uptrend.xyaxis",
                isUnlocked: false,
                category: .learning,
                rarity: .epic
            ),
            Achievement(
                id: "risk_expert",
                title: "Risk Navigator",
                description: "Complete risk management missions",
                icon: "shield.fill",
                isUnlocked: false,
                category: .learning,
                rarity: .rare
            ),
            Achievement(
                id: "wealth_builder",
                title: "Galactic Tycoon",
                description: "Accumulate 5,000 space credits",
                icon: "dollarsign.circle.fill",
                isUnlocked: false,
                category: .progress,
                rarity: .epic
            ),
            Achievement(
                id: "colony_growth",
                title: "Colony Builder",
                description: "Grow your colony to 500 inhabitants",
                icon: "building.2.fill",
                isUnlocked: false,
                category: .progress,
                rarity: .rare
            ),
            Achievement(
                id: "happy_colony",
                title: "Happiness Master",
                description: "Achieve 90% colony happiness",
                icon: "face.smiling.fill",
                isUnlocked: false,
                category: .progress,
                rarity: .epic
            ),
            Achievement(
                id: "experienced_commander",
                title: "Experienced Commander",
                description: "Reach level 5",
                icon: "star.circle.fill",
                isUnlocked: false,
                category: .progress,
                rarity: .rare
            ),
            Achievement(
                id: "veteran_commander",
                title: "Veteran Commander",
                description: "Reach level 10",
                icon: "crown.fill",
                isUnlocked: false,
                category: .progress,
                rarity: .legendary
            )
        ]
    }
}
