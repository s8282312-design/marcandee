import SwiftUI

// MARK: - ТОЧКА ВХОДА

@main
struct MarkandeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - МОДЕЛИ

struct Message: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var mine: Bool
    var time: String
}

struct Chat: Identifiable, Codable {
    var id: String
    var name: String
    var username: String
    var avatar: String
    var color: String
    var online: Bool
    var unread: Int
    var members: Int
    var messages: [Message]
}

struct Player: Codable {
    var rubles = 0
    var stars = 0
    var level = 1
    var xp = 0
    var reputation = 10
    var subscribers = 0
    var clients = 0
    var energy = 100
    var trust = 50
    var fame = 0
    var botLevel = 0
    var channelLevel = 0
    var pepe = false
    var goldenPepe = false
    var diamondPepe = false
    var pepeLevel = 0
    var goldenLevel = 0
    var diamondLevel = 0
    var casinoCoins = 100
    var bossHP = 300
    var bossUnlocked = false
    var bossWins = 0
    var completed: [Int] = []
    var achievements: [String] = []
    var storyPhase = 0
    var snoserProgress = 0
    var scandeUz = "@Iayaway"
    var markelovUz = "@heellenop"
    var log = "ЛУДКА РИЧЕВА · 1 247 участников · лут онлайн"
}

// MARK: - ИГРА

final class Game: ObservableObject {
    @Published var player: Player { didSet { save() } }
    @Published var chats: [Chat] { didSet { saveChats() } }
    @Published var selectedChat: String? = nil
    @Published var notice: String? = nil
    @Published var showBoat = true

    init() {
        if let d = UserDefaults.standard.data(forKey: "mk_player"),
           let p = try? JSONDecoder().decode(Player.self, from: d) {
            player = p
            showBoat = p.storyPhase == 0
        } else {
            player = Player()
        }
        if let d = UserDefaults.standard.data(forKey: "mk_chats"),
           let c = try? JSONDecoder().decode([Chat].self, from: d) {
            chats = c
        } else {
            chats = Self.initialChats
        }
    }

    static let initialChats: [Chat] = [
        Chat(id: "richev", name: "ЛУДКА РИЧЕВА", username: "@richev_loot",
             avatar: "🕴️", color: "gold", online: true, unread: 3, members: 1247,
             messages: [
                Message(text: "В лудку залетел новый лут: 3 юза, 2 номера +888. Кто первый — того и лут.", mine: false, time: "23:40"),
                Message(text: "@heellenop @Iayaway, вы новенькие? Берите, пока дают. Тут очередь.", mine: false, time: "23:41"),
                Message(text: "Сносер? Удачи. Тут такие уже были. Тысяча таких.", mine: false, time: "23:42")
             ]),
        Chat(id: "scande", name: "Scande", username: "@Iayaway",
             avatar: "🤓", color: "blue", online: true, unread: 1, members: 2,
             messages: [
                Message(text: "Я тут админ, @heellenop. Новенький? Первый раз вижу.", mine: false, time: "23:43"),
                Message(text: "Сносер? Ну давай. Только я не обещаю, что получится.", mine: false, time: "23:44")
             ]),
        Chat(id: "markelov", name: "Markelov", username: "@heellenop",
             avatar: "😎", color: "purple", online: true, unread: 0, members: 2,
             messages: [
                Message(text: "Слушай, у меня идея — Сносер. Замутим?", mine: false, time: "23:45")
             ]),
        Chat(id: "investor", name: "Unknown Investor", username: "@investor_888",
             avatar: "🕴️", color: "gold", online: false, unread: 0, members: 2,
             messages: [
                Message(text: "Здравствуйте. У меня предложение на миллион.", mine: false, time: "11:15")
             ]),
        Chat(id: "support", name: "Telegram Support", username: "@fake_support",
             avatar: "⚠️", color: "red", online: false, unread: 0, members: 2,
             messages: [
                Message(text: "Внимание! Ваш бот получил предупреждение.", mine: false, time: "10:40")
             ])
    ]

    var levelName: String {
        switch player.level {
        case 1: return "Школьник"
        case 2: return "Новичок"
        case 3: return "Предприниматель"
        case 4: return "Местная легенда"
        default: return "Профессиональный Скамер"
        }
    }

    var nextXP: Int { player.level * 100 }
    var nftCount: Int { [player.pepe, player.goldenPepe, player.diamondPepe].filter { $0 }.count }

    func save() {
        if let d = try? JSONEncoder().encode(player) {
            UserDefaults.standard.set(d, forKey: "mk_player")
        }
    }
    func saveChats() {
        if let d = try? JSONEncoder().encode(chats) {
            UserDefaults.standard.set(d, forKey: "mk_chats")
        }
    }

    func notify(_ t: String) { notice = t }

    func addXP(_ amount: Int) {
        player.xp += amount
        while player.level < 5 {
            let threshold = player.level * 100
            guard player.xp >= threshold else { break }
            player.xp -= threshold
            player.level += 1
            player.reputation = min(100, player.reputation + 5)
            notify("Новый уровень: \(levelName)!")
        }
    }

    func achievement(_ id: String) {
        if !player.achievements.contains(id) { player.achievements.append(id) }
    }

    // MARK: СЮЖЕТ

    func meetInLudka() {
        guard player.storyPhase == 0 else { return }
        player.storyPhase = 1
        player.log = "Ты в лудке Ричева. Scande — админ."
        achievement("lootka")
        showBoat = false
        notify("ЛУДКА РИЧЕВА: знакомство")
    }

    func buildSnoser() {
        guard player.storyPhase == 1 else { return }
        player.snoserProgress += 1
        if player.snoserProgress >= 10 {
            player.storyPhase = 2
            player.botLevel = 1
            player.log = "СНОСЕР ВСЕХ СНОСЕР собран. Не работает. Но собран."
            notify("Сносер собран... но он никого не сносит.")
            achievement("snoser_built")
        }
    }

    func launchSnoserScam() {
        guard player.storyPhase == 2 else { return }
        let roll = Int.random(in: 1...100)
        if roll <= 60 {
            player.rubles += Int.random(in: 500...600)
            player.stars += 600
            player.log = "Неожиданно! Сносер принёс профит."
            achievement("first_profit")
            notify("Первый профит: +500–600₽ +600⭐")
        } else {
            player.log = "Сносер выдал фейк-данные. Опять."
            notify("Сносер сломался. Опять.")
        }
        player.storyPhase = 3
        addXP(50)
    }

    func buyChannel() {
        guard player.storyPhase == 3, player.rubles >= 300 else {
            notify("Нужно 300₽ на канал.")
            return
        }
        player.rubles -= 300
        player.channelLevel = 1
        player.storyPhase = 4
        player.log = "ТГК куплен. Раздаём подарки, набираем народ."
        achievement("channel")
        notify("ТГК создан!")
    }

    func channelFail() {
        guard player.storyPhase == 4 else { return }
        player.fame = max(0, player.fame - 5)
        player.log = "Подписчики ушли. Подарки раздали зря."
        notify("ТГК провалился.")
        player.storyPhase = 5
    }

    func nftScamArc() {
        guard player.storyPhase == 5 else { return }
        let scandeRoll = Int.random(in: 1...100)
        let markelovRoll = Int.random(in: 1...100)
        if scandeRoll <= 75 { player.stars += 300; player.log = "Scande: скам удался!" }
        if markelovRoll <= 25 { player.rubles += 200; player.log += " Markelov: тоже!" }
        else { player.log += " Markelov: опять не вышло." }
        player.storyPhase = 6
        notify(player.log)
    }

    func mexicanScam() {
        guard player.storyPhase == 6 else { return }
        player.rubles += 400
        player.trust = min(100, player.trust + 20)
        player.log = "Мексиканец заскамлен. Markelov и Scande подружились."
        achievement("mexican")
        player.storyPhase = 7
        notify("Дружба! +400₽")
    }

    func scandeBecomesRichev() {
        guard player.storyPhase == 7 else { return }
        player.fame = min(100, player.fame + 15)
        player.log = "Scande встаёт как Ричев. Начинает получаться."
        player.storyPhase = 8
        notify("Scande растёт. FAME +15")
    }

    // MARK: РАЗРАБОТКА МАРКАНДЕ

    func developMarkande() {
        guard player.storyPhase >= 8, player.botLevel < 5 else {
            notify("Разработка Марканде завершена или недоступна.")
            return
        }
        let cost = player.botLevel * 200
        guard player.rubles >= cost else {
            notify("Нужно \(cost)₽ на разработку.")
            return
        }
        player.rubles -= cost
        player.botLevel += 1
        player.fame = min(100, player.fame + 3)
        player.log = "Scande пишет код Марканде. Markelov ищет людей."
        addXP(40)
        notify("Марканде: уровень \(player.botLevel)")
    }

    func markelovRecruit() {
        guard player.storyPhase >= 8 else { return }
        guard player.energy >= 10 else { notify("Мало энергии."); return }
        player.energy -= 10
        let gained = Int.random(in: 5...20)
        player.subscribers += gained
        player.fame = min(100, player.fame + 2)
        player.log = "Markelov привёл +\(gained) человек в лудку."
        notify("Markelov: +\(gained) подписчиков")
    }

    // MARK: СХЕМЫ

    func scam(_ scheme: Int) {
        guard player.energy >= 10 else { notify("Мало энергии."); return }
        player.energy -= 10
        let scandeBonus = 15
        let markelovPenalty = -10
        let base: Int
        switch scheme {
        case 0: base = 60
        case 1: base = 50
        default: base = 40
        }
        let chance = base + scandeBonus
        let roll = Int.random(in: 1...100)
        if roll <= chance {
            let reward: (Int, Int)
            switch scheme {
            case 0: reward = (300, 200)
            case 1: reward = (500, 0)
            default: reward = (800, 400)
            }
            player.rubles += reward.0
            player.stars += reward.1
            player.log = "Скам удался! +\(reward.0)₽ +\(reward.1)⭐"
            addXP(25)
            achievement("first_profit")
        } else {
            player.log = "Скам провалился. Markelov снова облажался."
            player.reputation = max(0, player.reputation - 2)
        }
        notify(player.log)
    }

    // MARK: РАБОТЫ / ЭНЕРГИЯ

    func job(_ name: String, reward: Int, energy: Int) {
        guard player.energy >= energy else { notify("Мало энергии."); return }
        player.energy -= energy
        if Int.random(in: 1...100) <= 75 {
            player.rubles += reward
            player.stars += 20
            addXP(25)
            notify("\(name): успех! +\(reward)₽")
        } else {
            player.rubles = max(0, player.rubles - 50)
            notify("\(name): провал. -50₽")
        }
    }

    func rest() {
        player.energy = min(100, player.energy + 40)
        notify("Энергия восстановлена.")
    }

    // MARK: NFT

    func buyNFT(_ id: String) {
        let price: Int
        switch id {
        case "pepe": price = 600
        case "gold": price = 2500
        default: price = 5000
        }
        let owned: Bool
        switch id {
        case "pepe": owned = player.pepe
        case "gold": owned = player.goldenPepe
        default: owned = player.diamondPepe
        }
        guard !owned else { notify("Уже есть."); return }
        guard player.stars >= price else { notify("Мало звёзд."); return }
        player.stars -= price
        switch id {
        case "pepe": player.pepe = true
        case "gold": player.goldenPepe = true
        default: player.diamondPepe = true
        }
        addXP(30)
        achievement("nft")
        notify("NFT куплен!")
    }

    func upgradeNFT(_ id: String) {
        let cost: Int
        switch id {
        case "pepe":
            guard player.pepe, player.pepeLevel < 6 else { return }
            cost = (player.pepeLevel + 1) * 300
        case "gold":
            guard player.goldenPepe, player.goldenLevel < 4 else { return }
            cost = (player.goldenLevel + 1) * 800
        default:
            guard player.diamondPepe, player.diamondLevel < 3 else { return }
            cost = (player.diamondLevel + 1) * 2000
        }
        guard player.stars >= cost else { notify("Мало звёзд."); return }
        player.stars -= cost
        switch id {
        case "pepe": player.pepeLevel += 1
        case "gold": player.goldenLevel += 1
        default: player.diamondLevel += 1
        }
        addXP(20)
        notify("NFT улучшен!")
    }

    // MARK: КАЗИНО

    func casino() {
        guard player.casinoCoins >= 10 else { notify("Нет жетонов."); return }
        player.casinoCoins -= 10
        if Int.random(in: 1...100) <= 40 {
            player.casinoCoins += 25
            notify("Победа! +25 жетонов.")
        } else {
            notify("Не повезло.")
        }
    }

    // MARK: БОСС

    var playerHP: Int {
        50 + (player.pepe ? 10 : 0) + (player.goldenPepe ? 25 : 0) + (player.diamondPepe ? 50 : 0)
    }

    func bossFight() {
        guard player.stars >= 20000 else {
            notify("Нужно 20 000 ⭐ для босса.")
            return
        }
        player.bossUnlocked = true
        let damage = (player.pepeLevel * 5) + (player.goldenLevel * 10) + (player.diamondLevel * 20) + Int.random(in: 5...15)
        player.bossHP = max(0, player.bossHP - damage)

        if player.bossHP == 0 {
            player.bossWins += 1
            player.reputation = 100
            player.pepeLevel = 6
            player.goldenLevel = 4
            player.diamondLevel = 3
            achievement("boss")
            notify("ПОБЕДА! ТЫ КОРОЛЬ СКАМА!")
        } else {
            let bossDamage = Int.random(in: 10...25)
            if bossDamage >= playerHP {
                player.pepe = false; player.goldenPepe = false; player.diamondPepe = false
                player.pepeLevel = 0; player.goldenLevel = 0; player.diamondLevel = 0
                player.rubles /= 2
                notify("Ричев заскамил тебя! NFT потеряны.")
            } else {
                notify("Урон: \(damage). HP босса: \(player.bossHP)")
            }
        }
    }

    func reset() {
        player = Player()
        chats = Self.initialChats
        showBoat = true
    }

    // MARK: ЧАТЫ

    func send(_ id: String, _ text: String) {
        guard let i = chats.firstIndex(where: { $0.id == id }) else { return }
        let t = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        chats[i].messages.append(Message(text: text, mine: true, time: t))
    }

    func receive(_ id: String, _ text: String) {
        guard let i = chats.firstIndex(where: { $0.id == id }) else { return }
        chats[i].messages.append(Message(text: text, mine: false, time: "Сейчас"))
    }

    func reply(_ id: String, _ choice: Int) {
        if id == "scande" {
            send(id, choice == 0 ? "Замутим Сносера!" : "Давай подумаем.")
            receive(id, choice == 0 ? "Погнали. Я в деле." : "Ты как всегда.")
            player.trust = min(100, player.trust + (choice == 0 ? 10 : -5))
        } else if id == "investor" {
            send(id, choice == 0 ? "Покажите документы." : "Звучит подозрительно.")
            receive(id, choice == 0 ? "Эээ... связь пропала." : "Вы слишком осторожны.")
            player.reputation = min(100, player.reputation + (choice == 0 ? 2 : 0))
        } else {
            send(id, "Спасибо!")
        }
    }
}

// MARK: - ЦВЕТА

extension Color {
    static let tgBackground = Color(red: 0.055, green: 0.075, blue: 0.105)
    static let tgPanel = Color(red: 0.10, green: 0.125, blue: 0.17)
    static let tgBlue = Color(red: 0.24, green: 0.58, blue: 0.88)
    static let tgGold = Color(red: 0.95, green: 0.70, blue: 0.28)
    static let tgGreen = Color(red: 0.25, green: 0.60, blue: 0.40)
}

// MARK: - КОРЕНЬ

struct RootView: View {
    @StateObject var game = Game()

    var body: some View {
        ZStack {
            Color.tgBackground.ignoresSafeArea()
            if game.showBoat {
                LudkaIntroView(game: game)
            } else {
                MainView(game: game)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - СЦЕНА ЛУДКИ

struct LudkaIntroView: View {
    @ObservedObject var game: Game

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🕴️").font(.system(size: 80))
            Text("ЛУДКА РИЧЕВА")
                .font(.system(size: 24, weight: .black))
            Text("23:47 · 1 247 участников · лут онлайн")
                .font(.caption).foregroundStyle(.gray)

            VStack(alignment: .leading, spacing: 10) {
                bubble("🕴️", "Александр Ричев", "В лудку залетел новый лут. Кто первый — того и лут.", false)
                bubble("🕴️", "Александр Ричев", "@heellenop @Iayaway, берите, пока дают.", false)
                bubble("🤓", "@Iayaway", "Я тут админ, @heellenop. Новенький?", false)
                bubble("😎", "@heellenop", "Да. Слушай, у меня идея — Сносер. Замутим?", true)
            }
            .padding(.horizontal)

            Spacer()

            Button { game.meetInLudka() } label: {
                Text("Взять лут")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.tgGold).foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal).padding(.bottom, 30)
        }
    }

    func bubble(_ avatar: String, _ name: String, _ text: String, _ mine: Bool) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(avatar).font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.caption.bold()).foregroundStyle(mine ? Color.tgGold : .white)
                Text(text).font(.system(size: 14))
            }
            .padding(10)
            .background(mine ? Color.tgBlue.opacity(0.3) : Color.tgPanel)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - ГЛАВНЫЙ ЭКРАН

struct MainView: View {
    @ObservedObject var game: Game
    @State private var tab = 0

    var body: some View {
        ZStack {
            Color.tgBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                Group {
                    switch tab {
                    case 0: chatsScreen
                    case 1: botScreen
                    case 2: channelScreen
                    case 3: nftScreen
                    default: profileScreen
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomBar
            }

            if let notice = game.notice {
                VStack {
                    HStack {
                        Image(systemName: "bell.fill").foregroundStyle(Color.tgGold)
                        Text(notice).font(.system(size: 13, weight: .medium))
                        Spacer()
                        Button { game.notice = nil } label: { Image(systemName: "xmark") }
                    }
                    .padding().background(Color.tgPanel)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 12).padding(.top, 8)
                    Spacer()
                }
                .zIndex(10)
            }
        }
    }

    var header: some View {
        HStack(spacing: 12) {
            Circle().fill(Color.tgBlue).frame(width: 42, height: 42)
                .overlay { Text("M").font(.title2.bold()) }
            VStack(alignment: .leading, spacing: 2) {
                Text("МАРКАНДЕ").font(.system(size: 18, weight: .black))
                Text("скам-симулятор").font(.system(size: 10)).foregroundStyle(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(game.player.rubles) ₽").font(.system(size: 13, weight: .bold))
                Text("\(game.player.stars) ⭐").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.tgGold)
            }
            Button { game.rest() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                    Text("\(game.player.energy)").font(.caption.bold())
                }
                .foregroundStyle(Color.tgGold)
                .padding(10).background(Color.tgBackground).clipShape(Capsule())
            }
        }
        .padding().background(Color.tgPanel)
    }

    var bottomBar: some View {
        HStack {
            nav("bubble.left.and.bubble.right.fill", "Чаты", 0)
            nav("robot", "Бот", 1)
            nav("megaphone.fill", "ТГК", 2)
            nav("gift.fill", "NFT", 3)
            nav("person.fill", "Профиль", 4)
        }
        .padding(.vertical, 10).background(Color.tgPanel)
    }

    func nav(_ icon: String, _ title: String, _ index: Int) -> some View {
        Button { tab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 19))
                Text(title).font(.system(size: 9))
            }
            .foregroundStyle(tab == index ? Color.tgBlue : .gray)
            .frame(maxWidth: .infinity)
        }
    }

    // ЧАТЫ
    var chatsScreen: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HStack {
                        Text("Сообщения").font(.system(size: 23, weight: .bold))
                        Spacer()
                        Text("ONLINE").font(.caption.bold()).foregroundStyle(.green)
                    }.padding()

                    ForEach(game.chats) { chat in
                        NavigationLink {
                            ChatView(game: game, chatID: chat.id)
                        } label: { chatRow(chat) }
                        .buttonStyle(.plain)
                    }
                }
            }
            .background(Color.tgBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    func chatRow(_ chat: Chat) -> some View {
        HStack(spacing: 13) {
            Circle().fill(avatarColor(chat.color)).frame(width: 52, height: 52)
                .overlay { Text(chat.avatar).font(.system(size: 25)) }
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(chat.name).bold()
                    Spacer()
                    Text(chat.messages.last?.time ?? "").font(.caption2).foregroundStyle(.gray)
                }
                HStack {
                    Text(chat.messages.last?.text ?? "").font(.caption).foregroundStyle(.gray).lineLimit(1)
                    Spacer()
                    if chat.unread > 0 {
                        Text("\(chat.unread)").font(.caption2.bold()).padding(6)
                            .background(Color.tgBlue).clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal).padding(.vertical, 12)
    }

    func avatarColor(_ c: String) -> Color {
        switch c {
        case "purple": return .purple
        case "blue": return .blue
        case "gold": return .orange
        case "red": return .red
        default: return .green
        }
    }

    // БОТ
    var botScreen: some View {
        ScrollView {
            VStack(spacing: 17) {
                title("БОТ МАРКАНДЕ", "Scande пишет · Markelov ищет людей")

                VStack(alignment: .leading, spacing: 13) {
                    HStack {
                        Image(systemName: "paperplane.fill").font(.largeTitle)
                        Spacer()
                        Text(game.player.botLevel > 0 ? "ONLINE" : "DEV").font(.caption.bold())
                    }
                    Text("@MARKANDE_BOT").font(.title.bold())
                    Text("Уровень \(game.player.botLevel)/5").foregroundStyle(.white.opacity(0.7))
                    HStack {
                        stat("Клиенты", "\(game.player.clients)")
                        stat("FAME", "\(game.player.fame)")
                        stat("Репутация", "\(game.player.reputation)")
                    }
                }
                .padding()
                .background(LinearGradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 22))

                if game.player.storyPhase == 1 || game.player.storyPhase == 2 {
                    Text("Сносер: \(game.player.snoserProgress)/10 тапов")
                        .font(.caption).foregroundStyle(.gray)
                    action("Собрать Сносера", "VPN · Proxy · гипсик", 0) { game.buildSnoser() }
                }

                if game.player.storyPhase == 2 {
                    action("Запустить скам на Сносере", "60/40 · 500–600₽", 0) { game.launchSnoserScam() }
                }

                if game.player.storyPhase == 3 {
                    action("Купить ТГК", "300₽ · раздача подарков", 300) { game.buyChannel() }
                }

                if game.player.storyPhase == 4 {
                    action("Провалить ТГК", "план не сработал", 0) { game.channelFail() }
                }

                if game.player.storyPhase == 5 {
                    action("Скам на NFT", "Scande 75% · Markelov 25%", 0) { game.nftScamArc() }
                }

                if game.player.storyPhase == 6 {
                    action("Скам мексиканца", "дружба +400₽", 0) { game.mexicanScam() }
                }

                if game.player.storyPhase == 7 {
                    action("Scande встаёт как Ричев", "FAME +15", 0) { game.scandeBecomesRichev() }
                }

                if game.player.storyPhase >= 8 {
                    action("Разработка Марканде", "казино · звёзды · скам-база", game.player.botLevel * 200) { game.developMarkande() }
                    action("Markelov ищет людей", "в лудку · +5–20 подписчиков", 0) { game.markelovRecruit() }
                }

                if game.player.botLevel > 0 {
                    title("СХЕМЫ", "рандом 60/40")
                    action("Бесплатные звёзды", "+300₽ +200⭐", 0) { game.scam(0) }
                    action("Продажа юза", "+500₽", 0) { game.scam(1) }
                    action("Крипто-раздача", "+800₽ +400⭐", 0) { game.scam(2) }
                }

                title("ИГРОВЫЕ РАБОТЫ", "энергия → деньги")
                action("🎣 Рыбалка", "180₽ · 10⚡", 0) { game.job("Рыбалка", reward: 180, energy: 10) }
                action("⚡ Электрик", "250₽ · 15⚡", 0) { game.job("Электрик", reward: 250, energy: 15) }
                action("🔧 Механик", "300₽ · 20⚡", 0) { game.job("Механик", reward: 300, energy: 20) }
                action("🏭 Завод", "400₽ · 25⚡", 0) { game.job("Завод", reward: 400, energy: 25) }
                action("⛏️ Шахта", "500₽ · 30⚡", 0) { game.job("Шахта", reward: 500, energy: 30) }

                Text(game.player.log).font(.caption).foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding().background(Color.tgPanel)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
    }

    // ТГК
    var channelScreen: some View {
        ScrollView {
            VStack(spacing: 18) {
                title("ТВОЙ ТГК", "медейство и пиар Марканде")
                VStack(spacing: 12) {
                    Text("📢").font(.system(size: 50))
                    Text("МАРКАНДЕ | OFFICIAL").font(.title3.bold())
                    Text("Новости, мемы и две легенды.").font(.caption).foregroundStyle(.gray)
                    Divider()
                    HStack {
                        stat("Подписчики", "\(game.player.subscribers)")
                        stat("Уровень", "\(game.player.channelLevel)")
                        stat("FAME", "\(game.player.fame)")
                    }
                }
                .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 20))

                action("Продвинуть канал", "найти подписчиков", game.player.channelLevel * 200) {
                    guard game.player.rubles >= game.player.channelLevel * 200 else {
                        game.notify("Мало рублей."); return
                    }
                    game.player.rubles -= game.player.channelLevel * 200
                    game.player.channelLevel += 1
                    let s = Int.random(in: 10...50)
                    game.player.subscribers += s
                    game.player.fame = min(100, game.player.fame + 3)
                    game.notify("Канал +\(s) подписчиков!")
                }

                title("ПОСТЫ", "лента")
                post("😎", "@heellenop", "Мы запустили Марканде! 🚀")
                post("🤓", "@Iayaway", "Казино уже работает. Почти.")
                post("🐸", "Марканде", "Первая коллекция Pepe доступна.")
            }
            .padding()
        }
    }

    func post(_ avatar: String, _ name: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text(avatar); Text(name).bold(); Spacer(); Text("12:30").font(.caption2).foregroundStyle(.gray) }
            Text(text).font(.system(size: 14))
            HStack { Label("24", systemImage: "eye"); Spacer(); Image(systemName: "heart"); Image(systemName: "paperplane") }
                .font(.caption).foregroundStyle(.gray)
        }
        .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 15))
    }

    // NFT
    var nftScreen: some View {
        ScrollView {
            VStack(spacing: 17) {
                title("NFT MARKET", "подарки и аренда")
                HStack {
                    Text("Твои звёзды"); Spacer()
                    Text("\(game.player.stars) ⭐").foregroundStyle(Color.tgGold).bold()
                }
                .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 14))

                nft("🐸", "Pepe Classic", "ОБЫЧНЫЙ", 600, game.player.pepe, "pepe", .green, game.player.pepeLevel, 6)
                nft("👑", "Golden Pepe", "ЭПИЧЕСКИЙ", 2500, game.player.goldenPepe, "gold", .orange, game.player.goldenLevel, 4)
                nft("💎", "Diamond Pepe", "ЛЕГЕНДАРНЫЙ", 5000, game.player.diamondPepe, "diamond", .blue, game.player.diamondLevel, 3)

                Text("Коллекция: \(game.nftCount)/3").foregroundStyle(.gray)

                title("КАЗИНО", "ставка 10 жетонов")
                HStack {
                    Text("Жетоны: \(game.player.casinoCoins)")
                    Spacer()
                    Button("Крутить") { game.casino() }
                        .buttonStyle(.borderedProminent).tint(.purple)
                }
                .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
    }

    func nft(_ emoji: String, _ name: String, _ rarity: String, _ price: Int,
             _ owned: Bool, _ id: String, _ color: Color, _ lvl: Int, _ maxLvl: Int) -> some View {
        VStack(spacing: 12) {
            Text(emoji).font(.system(size: 65))
            Text(name).font(.title3.bold())
            Text(rarity).font(.caption.bold()).foregroundStyle(color)
            Text(owned ? "Уровень \(lvl)/\(maxLvl)" : "\(price) ⭐")
            HStack {
                Button(owned ? "Куплено" : "Купить") { game.buyNFT(id) }
                    .buttonStyle(.borderedProminent).tint(color).disabled(owned)
                if owned && lvl < maxLvl {
                    Button("Улучшить") { game.upgradeNFT(id) }
                        .buttonStyle(.bordered).tint(color)
                }
            }
        }
        .frame(maxWidth: .infinity).padding()
        .background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // ПРОФИЛЬ
    var profileScreen: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text("😎").font(.system(size: 75))
                Text("MARKANDE USER").font(.title.bold())
                Text(game.levelName).foregroundStyle(Color.tgGold)

                VStack(alignment: .leading, spacing: 8) {
                    HStack { Text("Опыт"); Spacer(); Text("\(game.player.xp)/\(game.nextXP)") }
                    ProgressView(value: Double(game.player.xp), total: Double(game.nextXP)).tint(Color.tgBlue)
                    HStack { Text("FAME"); Spacer(); Text("\(game.player.fame)/100") }
                    ProgressView(value: Double(game.player.fame), total: 100).tint(Color.tgGold)
                }
                .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 15))

                HStack {
                    stat("Рубли", "\(game.player.rubles)")
                    stat("Звёзды", "\(game.player.stars)")
                    stat("NFT", "\(game.nftCount)")
                }
                HStack {
                    stat("Клиенты", "\(game.player.clients)")
                    stat("Подписчики", "\(game.player.subscribers)")
                }

                title("ДОСТИЖЕНИЯ", "твои награды")
                ach("Знакомство в лудке", "🚣", game.player.achievements.contains("lootka"))
                ach("Первая неудача", "💀", game.player.achievements.contains("snoser_built"))
                ach("Первая прибыль", "💰", game.player.achievements.contains("first_profit"))
                ach("ТГК создан", "📢", game.player.achievements.contains("channel"))
                ach("Бабки на хате", "🐸", game.player.achievements.contains("nft"))
                ach("Мексиканец", "🌮", game.player.achievements.contains("mexican"))
                ach("Убийца Скама", "👑", game.player.achievements.contains("boss"))

                // БОСС
                title("БОСС · АЛЕКСАНДР РИЧЕВ", "20 000 ⭐")
                VStack(spacing: 8) {
                    ProgressView(value: Double(game.player.bossHP), total: 300).tint(.red)
                    Text("HP босса: \(game.player.bossHP)/300").font(.caption).foregroundStyle(.gray)
                    Text("Твой HP: \(game.playerHP)").font(.caption).foregroundStyle(Color.tgGreen)
                    Button("⚔️ Атаковать") { game.bossFight() }
                        .buttonStyle(.borderedProminent).tint(.red)
                        .disabled(game.player.stars < 20000)
                }
                .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 15))

                if game.player.bossWins > 0 {
                    Text("Продолжение в следующем обновлении. Скам не заканчивается.")
                        .font(.caption).foregroundStyle(Color.tgGold)
                        .multilineTextAlignment(.center).padding()
                }

                Button(role: .destructive) { game.reset() } label: {
                    Label("Сбросить прогресс", systemImage: "trash").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered).padding(.top)
            }
            .padding()
        }
    }

    // HELPERS
    func title(_ name: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name).font(.system(size: 22, weight: .heavy))
            Text(subtitle).font(.caption).foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func stat(_ name: String, _ value: String) -> some View {
        VStack(spacing: 5) {
            Text(value).font(.headline.bold())
            Text(name).font(.caption2).foregroundStyle(.gray)
        }.frame(maxWidth: .infinity)
    }

    func action(_ name: String, _ desc: String, _ price: Int, run: @escaping () -> Void) -> some View {
        Button(action: run) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(name).font(.system(size: 15, weight: .bold)).foregroundStyle(.white)
                    Text(desc).font(.caption).foregroundStyle(.gray)
                }
                Spacer()
                Text(price == 0 ? "▶" : "\(price) ₽").font(.caption.bold()).foregroundStyle(Color.tgGold)
            }
            .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 15))
        }.buttonStyle(.plain)
    }

    func ach(_ name: String, _ emoji: String, _ unlocked: Bool) -> some View {
        HStack {
            Text(emoji).font(.title2)
            Text(name).font(.system(size: 14, weight: .medium))
            Spacer()
            Image(systemName: unlocked ? "checkmark.circle.fill" : "lock.fill")
                .foregroundStyle(unlocked ? .green : .gray)
        }
        .padding().background(Color.tgPanel).clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ЧАТ

struct ChatView: View {
    @ObservedObject var game: Game
    let chatID: String
    @State private var input = ""

    var chat: Chat? { game.chats.first(where: { $0.id == chatID }) }

    var body: some View {
        VStack(spacing: 0) {
            if let chat = chat {
                HStack {
                    Text(chat.avatar).font(.largeTitle)
                    VStack(alignment: .leading) {
                        Text(chat.name).bold()
                        Text(chat.online ? "в сети" : chat.username).font(.caption).foregroundStyle(.gray)
                    }
                    Spacer()
                    Button { game.notify("Звонки недоступны.") } label: { Image(systemName: "phone") }
                    Button { game.notify("Ещё: скоро.") } label: { Image(systemName: "ellipsis") }
                }
                .padding().background(Color.tgPanel)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(chat.messages) { m in
                                bubble(m).id(m.id)
                            }
                            if chatID == "scande" {
                                choices(["Замутим Сносера!", "Давай подумаем."])
                            }
                            if chatID == "investor" {
                                choices(["Покажите документы.", "Звучит подозрительно."])
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chat.messages.count) { _, _ in
                        if let last = chat.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                HStack(spacing: 10) {
                    Image(systemName: "paperclip").foregroundStyle(.gray)
                    TextField("Сообщение...", text: $input)
                    Button {
                        let t = input.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        game.send(chatID, t); input = ""
                    } label: {
                        Image(systemName: "paperplane.fill").foregroundStyle(Color.tgBlue).font(.title3)
                    }
                }
                .padding().background(Color.tgPanel)
            }
        }
        .background(Color.tgBackground)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if let i = game.chats.firstIndex(where: { $0.id == chatID }) {
                game.chats[i].unread = 0
            }
        }
    }

    func bubble(_ m: Message) -> some View {
        HStack {
            if m.mine { Spacer(minLength: 45) }
            VStack(alignment: .trailing, spacing: 5) {
                Text(m.text).font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(m.time).font(.system(size: 9)).foregroundStyle(.gray)
            }
            .padding(12)
            .background(m.mine ? Color.tgGreen : Color.tgPanel)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .frame(maxWidth: 290)
            if !m.mine { Spacer(minLength: 45) }
        }
    }

    func choices(_ values: [String]) -> some View {
        VStack(spacing: 8) {
            ForEach(values.indices, id: \.self) { i in
                Button { game.reply(chatID, i) } label: {
                    Text(values[i]).font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity).padding(12)
                        .background(Color.tgBlue.opacity(0.25))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }.padding(.vertical, 8)
    }
}
