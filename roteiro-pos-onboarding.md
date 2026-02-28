# Roteiro: Pós-Onboarding → Diagnóstico → Conta → Paywall → Home

## Visão Geral do Fluxo

```
Onboarding (8 steps)
    ↓
Tela de Diagnóstico Personalizado        ← valor REAL gerado localmente
    ↓
    ├── "Criar conta" → Auth (Apple / Email)
    │       ↓
    │       Paywall (free trial 7 dias)  ← momento de pico de motivação
    │       ↓
    │       ├── Assina trial
    │       │     ↓
    │       │     Se escolheu IA → Loading "Gerando ficha..." → POST /api
    │       │     ↓
    │       │     Home (MainTabView) — modo premium
    │       │
    │       └── Recusa trial
    │             ↓
    │             Home (MainTabView) — modo free (com feature gates)
    │
    └── "Continuar sem conta"
            ↓
            Home (MainTabView) — modo guest (limitado, sem paywall)
```

---

## Estado Atual

| Item | Status |
|------|--------|
| Onboarding (9 steps) | Concluído |
| AppRouter | Binário: `hasCompletedOnboarding` → MainTabView |
| Persistência do perfil | Não implementada (OnboardingProfile só vive em memória) |
| Autenticação | Não existe |
| Firebase | Não integrado |

---

## Regras da Apple sobre criação de conta

A Apple **não permite** forçar criação de conta sem justificativa funcional:

> **Guideline 5.1.1(v):** Apps cannot require users to enter personal information to function, except when directly relevant to the core functionality.
> **Guideline 3.1.2:** Se oferecer login social, deve oferecer Sign in with Apple.

### Decisão para o app:

| Funcionalidade | Sem conta | Com conta |
|----------------|-----------|-----------|
| Ver diagnóstico do plano | Sim | Sim |
| Criar fichas manualmente | Sim | Sim |
| Gerar fichas com IA | Não (requer servidor) | Sim |
| Sync/backup entre devices | Não | Sim |
| Histórico de treinos na nuvem | Não | Sim |

O usuário pode usar o app sem conta, mas funcionalidades que dependem de servidor exigem autenticação. Isso é justificativa válida para o review da Apple.

---

## Etapa 1 — Persistência Local + AppState

**Objetivo:** Salvar o OnboardingProfile localmente e criar o sistema de estados do app.

### 1.1 Salvar OnboardingProfile no UserDefaults

**Arquivo:** `OnboardingViewModel.swift`

- No `completeOnboarding()`, codificar o `OnboardingProfile` (já é `Codable`) e salvar em `UserDefaults`
- Criar método estático `loadProfile() -> OnboardingProfile?` para recuperar

```swift
func completeOnboarding() {
    if let data = try? JSONEncoder().encode(profile) {
        UserDefaults.standard.set(data, forKey: "onboardingProfile")
    }
    // Transição para o próximo estado (diagnóstico)
}
```

### 1.2 Novo estado no AppRouter

**Arquivo:** `AppRouter.swift`

Trocar o binário `hasCompletedOnboarding` por um enum de estados:

```swift
enum AppState: String {
    case onboarding        // Primeira abertura
    case awaitingAccount   // Onboarding feito, mostrando diagnóstico
    case authenticated     // Conta criada (free ou premium)
    case guest             // Sem conta, modo limitado
}
```

O `AppRouter` passa a usar `@AppStorage("appState")` e faz o switch:

```
.onboarding      → OnboardingContainerView
.awaitingAccount → DiagnosticView → AuthView ou "Continuar sem conta"
.authenticated   → PaywallView (1ª vez) → MainTabView
.guest           → MainTabView (modo limitado, com banners de conversão)
```

> O paywall é mostrado **uma vez** após o primeiro login. Se o usuário recusar, vai pra Home em modo free. Feature gates dentro do app reapresentam o paywall quando ele tenta acessar funções premium.

---

## Etapa 2 — Tela de Diagnóstico Personalizado

**Objetivo:** Mostrar ao usuário um diagnóstico que **devolve valor**, com informações que ele NÃO forneceu mas o app deduziu. Isso cria o efeito "isso foi feito pra mim" e motiva a criação de conta.

### 2.1 Lógica de Cálculo Local — `PlanDiagnosticEngine`

**Novo arquivo:** `Core/Services/PlanDiagnosticEngine.swift`

Recebe um `OnboardingProfile` e retorna um `PlanDiagnostic` com tudo calculado. Sem IA — são tabelas de decisão baseadas nas combinações de variáveis do onboarding.

#### Dados de entrada (do OnboardingProfile):

```
objetivo + nível + dias + duração + idade + peso + altura + dislikes + sensíveis + equipamento
```

#### Dados de saída (calculados):

| Campo | Como calcular | Exemplo |
|-------|---------------|---------|
| **Split recomendado** | `dias` → tipo de divisão | "Upper/Lower — 4x por semana" |
| **Volume semanal** | `nível` + `objetivo` → séries/grupo | "14-16 séries por grupo muscular" |
| **Faixa de repetição** | `objetivo` → rep range | "8-12 repetições" |
| **Intensidade (RPE)** | `nível` + `objetivo` | "RPE 7-8" |
| **Exercícios por sessão** | `duração` → quantidade | "5-6 exercícios" |
| **Calorias por sessão** | `peso` + `duração` + `intensidade` | "~320 kcal" |
| **Grupos prioritários** | `allMuscles - dislikes - sensíveis` | "Peito, Costas, Pernas" |
| **Tempo p/ resultados** | `objetivo` + `nível` + `dias` | "Primeiros resultados em 6-8 semanas" |
| **Recomendação extra** | `IMC` + `objetivo` + `dias` | "Incluir caminhada nos dias de descanso" |

#### Tabelas de decisão:

**Split por dias disponíveis:**

| Dias | Iniciante | Intermediário | Avançado |
|------|-----------|---------------|----------|
| 1-2 | Full Body | Full Body | Full Body |
| 3 | Full Body | Full Body / PPL | Push/Pull/Legs |
| 4 | Upper/Lower | Upper/Lower | Upper/Lower |
| 5 | Upper/Lower + 1 | PPL + Upper/Lower | PPL + Upper/Lower |
| 6-7 | PPL | PPL | PPL (2x) |

**Volume (séries/grupo/semana) por nível × objetivo:**

| | Hipertrofia | Perda de peso | Força | Saúde | Resistência |
|---|---|---|---|---|---|
| Iniciante | 8-10 | 6-8 | 6-8 | 6-8 | 8-10 |
| Intermediário | 14-16 | 10-12 | 10-12 | 10-12 | 12-14 |
| Avançado | 18-22 | 14-16 | 12-16 | 12-14 | 16-18 |

**Faixa de repetição por objetivo:**

| Objetivo | Repetições | RPE Iniciante | RPE Intermediário | RPE Avançado |
|----------|-----------|---------------|-------------------|--------------|
| Hipertrofia | 8-12 | 6-7 | 7-8 | 8-9 |
| Perda de peso | 12-15 | 5-6 | 6-7 | 7-8 |
| Força | 3-6 | 6-7 | 7-8 | 8-9 |
| Saúde geral | 10-15 | 5-6 | 6-7 | 7-8 |
| Resistência | 15-20 | 5-6 | 6-7 | 7-8 |

**Exercícios por sessão (baseado em duração):**

| Duração | Exercícios | Descanso entre séries |
|---------|------------|----------------------|
| 30 min | 4-5 | 60-90s |
| 45 min | 5-6 | 90-120s |
| 60 min | 6-8 | 90-120s |
| 90 min | 8-10 | 120-180s |

**Estimativa calórica (por sessão):**

```
Base = peso_kg × 0.07 × duração_min
Ajuste por intensidade:
  - RPE 5-6: ×0.85
  - RPE 7-8: ×1.0
  - RPE 8-9: ×1.15
Arredondar para múltiplo de 10
```

**Tempo para resultados:**

| Objetivo | Iniciante | Intermediário | Avançado |
|----------|-----------|---------------|----------|
| Hipertrofia | 8-12 sem | 6-8 sem | 4-6 sem |
| Perda de peso | 4-6 sem | 3-5 sem | 2-4 sem |
| Força | 6-8 sem | 4-6 sem | 3-5 sem |
| Saúde geral | 3-4 sem | 2-3 sem | 2-3 sem |
| Resistência | 4-6 sem | 3-5 sem | 2-4 sem |

**Recomendações extras (por IMC + objetivo):**

| Condição | Recomendação |
|----------|-------------|
| IMC > 30 + qualquer objetivo | "Incluir caminhada leve nos dias de descanso" |
| IMC < 18.5 + hipertrofia | "Atenção à alimentação — superávit calórico é essencial" |
| Idade > 45 + qualquer | "Aquecimento articular de 5-10 min recomendado" |
| Dias ≤ 2 + hipertrofia | "Considere aumentar para 3x/sem quando possível" |
| Áreas sensíveis > 2 | "Exercícios alternativos serão priorizados para suas áreas sensíveis" |

### 2.2 `DiagnosticView`

**Novo arquivo:** `Features/Diagnostic/Views/DiagnosticView.swift`

**Layout visual:**

```
┌──────────────────────────────────┐
│  Passo 3 de 8   (stepTag)       │
│                                  │
│  SEU PLANO                       │  ← Bebas Neue display
│  PERSONALIZADO                   │
│                                  │
│  Baseado no seu perfil,          │
│  montamos seu plano ideal.       │
│                                  │
│  ┌────────────┐ ┌────────────┐   │
│  │ SPLIT      │ │ VOLUME     │   │
│  │ Upper/     │ │ 14-16      │   │
│  │ Lower      │ │ séries/sem │   │
│  └────────────┘ └────────────┘   │
│  ┌────────────┐ ┌────────────┐   │
│  │ REPETIÇÕES │ │ EXERCÍCIOS │   │
│  │ 8-12       │ │ 5-6/sessão │   │
│  └────────────┘ └────────────┘   │
│  ┌────────────┐ ┌────────────┐   │
│  │ CALORIAS   │ │ RESULTADOS │   │
│  │ ~320 kcal  │ │ em 6-8     │   │
│  │ /sessão    │ │ semanas    │   │
│  └────────────┘ └────────────┘   │
│                                  │
│  ┌──────────────────────────────┐│
│  │ 💡 Incluir caminhada nos    ││
│  │    dias de descanso          ││
│  └──────────────────────────────┘│
│                                  │
│  ┌──────────────────────────────┐│
│  │ GRUPOS PRIORITÁRIOS          ││
│  │ Peito · Costas · Pernas     ││
│  └──────────────────────────────┘│
│                                  │
│  [ Criar conta e começar ]       │  ← PrimaryButton
│  [ Continuar sem conta   ]       │  ← SecondaryButton / texto clicável
│                                  │
│  Crie sua conta para gerar sua   │
│  ficha personalizada com IA      │
└──────────────────────────────────┘
```

**Comportamento:**
- Cards aparecem com animação staggered (fade-up com delay incremental)
- "Criar conta e começar" → navega para `AuthView`
- "Continuar sem conta" → `appState = .guest` → MainTabView (modo limitado)

---

## Etapa 3 — Firebase Auth (Setup)

**Objetivo:** Integrar Firebase Authentication no projeto.

### 3.1 Configuração do Firebase

1. Criar projeto no [Firebase Console](https://console.firebase.google.com)
2. Registrar o app iOS (Bundle ID)
3. Baixar `GoogleService-Info.plist` e adicionar ao target
4. Adicionar dependência via SPM:
   - `https://github.com/firebase/firebase-ios-sdk`
   - Selecionar produto: `FirebaseAuth`
5. Inicializar no `FitnessAppApp.swift`:

```swift
import FirebaseCore

@main
struct FitnessAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    // ...
}
```

### 3.2 Habilitar provedores no Console

- **Email/Senha** — ativar em Authentication → Sign-in method
- **Apple** — ativar e configurar (requer Apple Developer Account)

### 3.3 Configurar Sign in with Apple no Xcode

1. Target → Signing & Capabilities → + Capability → "Sign in with Apple"
2. No Apple Developer Portal, habilitar o Sign in with Apple no App ID

---

## Etapa 4 — Serviço de Autenticação

**Objetivo:** Criar a camada de serviço que encapsula Firebase Auth.

### 4.1 `AuthService` (com protocolo para DI)

**Novo arquivo:** `Core/Services/AuthService.swift`

> Seguindo a diretriz do `guia-swift-senior.md`: todos os services devem ter protocolo para permitir mocks em testes e injeção de dependência.

```swift
import FirebaseAuth
import AuthenticationServices

// MARK: - Protocolo (para DI e testes)
protocol AuthServiceProtocol {
    var user: FirebaseAuth.User? { get }
    var isAuthenticated: Bool { get }
    func signUp(email: String, password: String) async throws
    func signIn(email: String, password: String) async throws
    func resetPassword(email: String) async throws
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async throws
    func signOut() throws
}

// MARK: - Implementação
@MainActor
final class AuthService: ObservableObject, AuthServiceProtocol {
    @Published var user: FirebaseAuth.User?
    @Published var isLoading = false
    @Published var error: String?

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        authListener = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    var isAuthenticated: Bool { user != nil }

    // MARK: - Email + Senha
    func signUp(email: String, password: String) async throws { ... }
    func signIn(email: String, password: String) async throws { ... }
    func resetPassword(email: String) async throws { ... }

    // MARK: - Apple
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async throws { ... }

    // MARK: - Logout
    func signOut() throws { ... }
}
```

### 4.2 Vincular perfil ao usuário

Após autenticação bem-sucedida:
1. Recuperar o `OnboardingProfile` salvo localmente
2. Associar ao `user.uid` do Firebase
3. Salvar no SwiftData (será a fonte de verdade local)
4. Marcar `appState = .authenticated`

---

## Etapa 5 — Telas de Autenticação

**Objetivo:** UI para Sign in with Apple + cadastro/login com email.

### 5.1 `AuthView` (Container)

**Novo arquivo:** `Features/Auth/Views/AuthView.swift`

Layout:
- Header visual (logo ou ícone do app)
- Botão **Sign in with Apple** (destaque principal, usando `SignInWithAppleButton` nativo)
- Divisor "ou"
- Botão secundário "Continuar com e-mail"

### 5.2 `EmailAuthView`

**Novo arquivo:** `Features/Auth/Views/EmailAuthView.swift`

Duas abas internas (criar conta / entrar):

**Criar conta:**
- Campo de email (InputField existente)
- Campo de senha (InputField com secureField)
- Campo confirmar senha
- Botão "Criar conta" (PrimaryButton)
- Validação: email válido, senha mín. 6 caracteres, senhas coincidem

**Entrar:**
- Campo de email
- Campo de senha
- Link "Esqueci minha senha"
- Botão "Entrar" (PrimaryButton)

### 5.3 `ForgotPasswordView`

**Novo arquivo:** `Features/Auth/Views/ForgotPasswordView.swift`

- Campo de email
- Botão "Enviar link de recuperação"
- Feedback visual de sucesso/erro

### 5.4 `AuthViewModel`

**Novo arquivo:** `Features/Auth/ViewModels/AuthViewModel.swift`

- Gerencia estados de loading, erro, validação
- Chama `AuthService` para as operações
- Após sucesso: salva perfil e navega para MainTabView

---

## Etapa 6 — Integrar no AppRouter

**Arquivo:** `AppRouter.swift`

```swift
struct AppRouter: View {
    @AppStorage("appState") private var appState: String = AppState.onboarding.rawValue
    @AppStorage("hasSeenPaywall") private var hasSeenPaywall = false
    @StateObject private var authService = AuthService()
    @StateObject private var subscriptionManager = SubscriptionManager()

    var body: some View {
        Group {
            switch AppState(rawValue: appState) ?? .onboarding {
            case .onboarding:
                OnboardingContainerView()
            case .awaitingAccount:
                DiagnosticView()
            case .authenticated:
                if !hasSeenPaywall {
                    PaywallView()   // mostrado 1x após primeiro login
                } else {
                    MainTabView()   // free ou premium (baseado em storeService.isPremium)
                }
            case .guest:
                MainTabView()       // modo limitado
            }
        }
        .environmentObject(authService)
        .environmentObject(subscriptionManager)
        .onChange(of: authService.isAuthenticated) { _, isAuth in
            if isAuth {
                // Vincular usuário ao RevenueCat para tracking cross-device
                Task { await subscriptionManager.identify(userId: authService.user?.uid ?? "") }
                appState = AppState.authenticated.rawValue
            }
        }
    }
}
```

> Dentro do `MainTabView`, usar `subscriptionManager.isSubscribed` para decidir o que é acessível. Usuários guest não veem o paywall inicial — só feature gates dentro do app se decidirem criar conta depois.

---

## Etapa 7 — Paywall

**Objetivo:** Apresentar o plano premium com free trial no momento de maior motivação — logo após criar conta.

### 7.1 Por que APÓS criar conta?

Dados da indústria (RevenueCat State of Subscriptions 2025, Superwall):

- O onboarding é responsável por **~50% de todos os trials iniciados** em apps de subscription
- O efeito **Sunk Cost** joga a favor: o usuário investiu tempo no onboarding + criou conta, não quer "perder" isso
- Mostrar o paywall **antes** da conta = fricção dupla (assinar + criar conta)
- Mostrar **depois** da conta = só uma decisão (aceitar trial grátis)
- Testes mostram que a posição do paywall pode variar a conversão em até **7.5×**

### 7.2 Modelo de monetização

**Free trial de 7 dias** (não é obrigatório, é decisão de negócio — mas é o padrão que mais converte em fitness):

| Métrica (Health & Fitness - RevenueCat 2025) | Mediana | Top 10% |
|-----------------------------------------------|---------|---------|
| Download → Trial | ~8% | ~20% |
| Trial → Paid | ~40% | ~68% |

O trial de 7 dias é o sweet spot:
- Longo o suficiente pra criar hábito (2-3 treinos)
- Curto o suficiente pra não esquecer que assinou
- Percepção de "risco zero" por parte do usuário

### 7.3 Três modos de acesso no app

| | Guest (sem conta) | Free (com conta) | Premium (assinante) |
|---|---|---|---|
| Diagnóstico do plano | Sim | Sim | Sim |
| Fichas manuais | 1 ficha | 1 ficha | Ilimitadas |
| Geração com IA | Não | Não | Sim |
| Treino ativo (timer) | Sim | Sim | Sim |
| Histórico | Últimos 7 dias | Últimos 7 dias | Completo |
| Análise de progresso | Não | Básica | Detalhada |
| Sync/backup na nuvem | Não | Não | Sim |
| Remover anúncios | — | — | Sim (se tiver) |

### 7.4 `PaywallView`

**Novo arquivo:** `Features/Paywall/Views/PaywallView.swift`

**Layout visual:**

```
┌──────────────────────────────────┐
│                            [ ✕ ] │  ← botão fechar (obrigatório)
│                                  │
│  DESBLOQUEIE                     │  ← Bebas Neue display
│  TODO SEU                        │
│  POTENCIAL                       │
│                                  │
│  ┌──────────────────────────────┐│
│  │ ✦ Fichas ilimitadas com IA  ││
│  │ ✦ Planos 100% personalizados││
│  │ ✦ Análise completa de       ││
│  │   progresso                  ││
│  │ ✦ Histórico ilimitado       ││
│  │ ✦ Backup na nuvem           ││
│  └──────────────────────────────┘│
│                                  │
│  ┌──────────────────────────────┐│
│  │      PLANO ANUAL             ││  ← card com badge "MELHOR VALOR"
│  │  R$ 14,90/mês               ││
│  │  (R$ 179,90/ano)            ││
│  │  Economize 37%              ││
│  └──────────────────────────────┘│
│  ┌──────────────────────────────┐│
│  │      PLANO MENSAL            ││
│  │  R$ 24,90/mês               ││
│  └──────────────────────────────┘│
│                                  │
│  [ Começar 7 dias grátis ]       │  ← PrimaryButton
│                                  │
│  7 dias grátis, depois           │  ← texto obrigatório (Apple)
│  R$ XX,XX/mês. Cancele           │
│  a qualquer momento.             │
│                                  │
│  Restaurar compra                │  ← link (obrigatório Apple)
│  Termos de Uso · Privacidade     │  ← links (obrigatório Apple)
│                                  │
│  [ Continuar com plano gratuito ]│  ← texto clicável, discreto
│                                  │
└──────────────────────────────────┘
```

### 7.5 Requisitos obrigatórios da Apple (Review Guidelines)

Sem esses itens, o app será **rejeitado**:

| Requisito | Guideline | Como atender |
|-----------|-----------|-------------|
| Preço visível na tela | 3.1.2 | Mostrar "R$ XX,XX/mês" ou "/ano" claramente |
| Duração do trial explícita | 3.1.2 | "7 dias grátis, depois R$ XX,XX/mês" |
| Informar auto-renovação | 3.1.2 | "Renovação automática. Cancele a qualquer momento." |
| Botão de restaurar compra | 3.1.2 | Link "Restaurar compra" visível |
| Termos de Uso | 3.1.2 | Link para página de termos |
| Política de Privacidade | 3.1.2 | Link para página de privacidade |
| Permitir fechar/recusar | 3.1.2 | Botão ✕ ou "Continuar com plano gratuito" |
| NÃO usar toggles confusos | 3.1.2 | Apple está rejeitando paywalls com toggle trial em 2025/2026 |

### 7.6 Feature Gates (paywalls contextuais dentro do app)

Além do paywall pós-auth, mostrar mini-paywalls quando o usuário free/guest toca em features premium:

| Trigger | Onde aparece |
|---------|-------------|
| Toca em "Gerar ficha com IA" | Sheet com benefícios + CTA |
| Tenta criar 2ª ficha manual | Sheet informando limite |
| Acessa histórico > 7 dias | Sheet com preview borrado + CTA |
| Acessa análise detalhada | Sheet com preview borrado + CTA |

Esses feature gates complementam o paywall principal e capturam usuários que recusaram o trial inicialmente mas agora sentem falta das features.

### 7.7 Implementação técnica (RevenueCat)

> **Por que RevenueCat e não StoreKit 2 direto?** Conforme definido no `guia-swift-senior.md` (seção 4.1): RevenueCat oferece dashboard de métricas, webhooks, cross-platform, e tratamento automático de edge cases (Ask to Buy, family sharing, grace period). Para um MVP, economiza semanas de backend.

**Novo arquivo:** `Services/RevenueCatService.swift`

```swift
import RevenueCat

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published var isSubscribed = false
    @Published var currentOffering: Offering?
    @Published var isLoading = false

    // MARK: - Setup (chamar no app launch)
    func configure() {
        Purchases.logLevel = .debug  // remover em produção
        Purchases.configure(withAPIKey: "your_revenuecat_api_key")
    }

    // MARK: - Verificar assinatura
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
        } catch { /* handle */ }
    }

    // MARK: - Carregar offerings
    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch { /* handle */ }
    }

    // MARK: - Comprar
    func purchase(package: Package) async -> Bool {
        do {
            isLoading = true
            let result = try await Purchases.shared.purchase(package: package)
            isSubscribed = result.customerInfo.entitlements["premium"]?.isActive == true
            isLoading = false
            return isSubscribed
        } catch {
            isLoading = false
            return false
        }
    }

    // MARK: - Restaurar
    func restorePurchases() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
            return isSubscribed
        } catch { return false }
    }

    // MARK: - Identificar usuário (após login)
    func identify(userId: String) async {
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(userId)
            isSubscribed = customerInfo.entitlements["premium"]?.isActive == true
        } catch { /* handle */ }
    }

    // MARK: - Logout
    func logout() async {
        _ = try? await Purchases.shared.logOut()
        isSubscribed = false
    }
}
```

> **Importante:** Verificar sempre `entitlements["premium"]?.isActive`, nunca product IDs diretamente. O RevenueCat abstrai isso e trata renovações, grace periods, etc.

**Product IDs (configurar no App Store Connect + dashboard RevenueCat):**
- `premium_monthly` — Plano mensal
- `premium_yearly` — Plano anual

**No dashboard RevenueCat:**
1. Criar Entitlement: `premium`
2. Criar Offering: `default`
3. Associar os products ao offering

### 7.8 `PaywallViewModel`

**Novo arquivo:** `Features/Paywall/ViewModels/PaywallViewModel.swift`

- Carrega offerings do RevenueCat (packages com preço localizado)
- Gerencia seleção de plano (mensal/anual)
- Processa compra via `SubscriptionManager.purchase(package:)`
- Trata erros (cancelamento, falha de rede, etc.)
- Usa `Package.localizedPriceString` para exibir preços (nunca hardcode)

### 7.9 Limites de uso e proteção anti-abuse

#### Problema: o que impede exploits no trial?

| Exploit | Risco real | Por quê |
|---------|-----------|---------|
| Tirar print de todas as fichas | Baixo | Ficha é temporária — precisa atualizar a cada 4-6 semanas com progressão. Print não tem timer, registro de carga, nem se adapta |
| Gerar muitas fichas com IA | Médio | Cada geração custa tokens de IA no backend. Sem limite, um trial pode gerar centenas |
| Criar várias contas para trial infinito | Baixo | A Apple bloqueia automaticamente pelo Apple ID / StoreKit (veja abaixo) |
| Compartilhar conta | Insignificante | Não vale se preocupar na fase atual |

#### Limites por tier

| Recurso | Trial (7 dias) | Premium | Free / Guest |
|---------|----------------|---------|--------------|
| Gerações com IA | **1 ficha** | 3 fichas/mês | Bloqueado |
| Fichas manuais | Ilimitadas | Ilimitadas | 1 ficha |
| Histórico | Completo | Completo | Últimos 7 dias |
| Análise de progresso | Detalhada | Detalhada | Básica / Não |
| Sync/backup | Sim | Sim | Não |

> O trial libera **1 geração com IA** — suficiente para o usuário ver o valor, pouco para explorar tudo. O valor real do premium é o **ciclo contínuo**: gerar → treinar → registrar → progredir → gerar nova ficha adaptada.

#### Proteção contra trial infinito (3 camadas)

**Camada 1 — Apple StoreKit (automática, mais forte):**

O free trial é vinculado ao **Apple ID**, não à conta do seu app. Se o mesmo Apple ID já usou um trial do seu app, a App Store cobra desde o primeiro dia — independente de quantas contas o usuário criar no app.

```
Usuário cria Conta A → Apple ID X → trial de 7 dias ✓
Usuário cria Conta B → Apple ID X → Apple cobra direto, sem trial ✗
```

Para burlar, precisaria de novo Apple ID + novo método de pagamento → esforço não compensa.

**Camada 2 — Keychain flag (persiste após deletar o app):**

Salvar um flag no Keychain do dispositivo na primeira ativação de trial. O Keychain **não é apagado** quando o usuário deleta o app.

```swift
// Ao ativar trial:
KeychainManager.set("hasUsedTrial", value: "true")

// Ao mostrar paywall:
let hasUsedTrial = KeychainManager.get("hasUsedTrial") == "true"
// Se true → não mostrar opção de trial, só compra direta
```

Para burlar, precisaria resetar o Keychain (reset de fábrica) → esforço extremo.

**Camada 3 — Firebase (verificação server-side, opcional futuro):**

Registrar no backend o `deviceId` + `userId` que ativaram trial. Bloquear combinações suspeitas (mesmo device, múltiplas contas).

> As camadas 1 e 2 são suficientes para o lançamento. Camada 3 só se houver evidência de abuse.

#### Limite de gerações — implementação

```swift
// No SubscriptionManager ou ProfileService:
struct GenerationLimits {
    static let trialMax = 1
    static let premiumMonthlyMax = 3

    static func canGenerate(currentCount: Int, isPremium: Bool, isTrial: Bool) -> Bool {
        if isTrial { return currentCount < trialMax }
        if isPremium { return currentCount < premiumMonthlyMax }
        return false // free/guest
    }
}
```

O contador de gerações reseta no primeiro dia de cada mês (salvo em SwiftData, vinculado ao `user.uid`).

#### Realidade sobre anti-abuse

Quem quer exploitar vai exploitar — mas o custo do esforço (novo Apple ID, novo email, novo método de pagamento, resetar Keychain) é **muito maior** do que R$24,90/mês. E quem faz isso **nunca ia pagar de qualquer forma** — não é receita perdida. O foco deve ser em entregar valor suficiente para que pagar seja a decisão óbvia.

---

## Etapa 8 — Geração de Ficha com IA (pós-auth + pós-paywall)

**Pré-requisito:** Backend próprio com endpoint de geração + usuário premium (trial ou assinante).

### Fluxo:

```
Usuário cria conta (Etapa 5) → Paywall (Etapa 7)
    ↓
Se workoutSetupChoice == .ai E isPremium == true
    ↓
Tela de loading animado ("Gerando sua ficha personalizada...")
    ↓
POST /api/generate-workout
    Header: Authorization: Bearer <firebase_token>
    Body: { OnboardingProfile completo }
    ↓
Response: { ficha com exercícios, séries, progressão }
    ↓
Salvar ficha no SwiftData
    ↓
Home (MainTabView)
```

Se o usuário escolheu IA mas **recusou o trial**, vai pra Home no modo free. A geração com IA aparece como feature gate — ao tocar, abre o paywall novamente.

### Arquitetura API + Auth:

```
Firebase Auth (login)  →  gera JWT token
        ↓
App envia token no header  →  Backend valida com Firebase Admin SDK
        ↓
Backend verifica subscription status (premium?)
        ↓
Backend processa  →  chama API de IA  →  retorna ficha
```

O Firebase Auth, o backend e o RevenueCat **se complementam**:
- Firebase cuida de quem o usuário é (auth)
- Backend cuida do que o app faz (lógica de negócio, IA)
- RevenueCat cuida de quem pagou (subscription status, entitlements, métricas)

> Esta etapa será detalhada em roteiro separado quando o backend estiver sendo desenvolvido.

---

## Estrutura de Pastas Final

```
Features/
├── Onboarding/              ← já existe
│   ├── Models/
│   ├── ViewModels/
│   └── Views/
├── Diagnostic/              ← NOVO (Etapa 2)
│   └── Views/
│       └── DiagnosticView.swift
├── Auth/                    ← NOVO (Etapa 5)
│   ├── Views/
│   │   ├── AuthView.swift
│   │   ├── EmailAuthView.swift
│   │   └── ForgotPasswordView.swift
│   └── ViewModels/
│       └── AuthViewModel.swift
├── Paywall/                 ← NOVO (Etapa 7)
│   ├── Views/
│   │   ├── PaywallView.swift
│   │   └── FeatureGateSheet.swift
│   └── ViewModels/
│       └── PaywallViewModel.swift
Core/
├── Services/                ← NOVO
│   ├── AuthService.swift            (Etapa 4)
│   └── PlanDiagnosticEngine.swift   (Etapa 2)
Services/
├── RevenueCatService.swift          (Etapa 7 — SubscriptionManager)
```

---

## Ordem de Implementação (Prompts)

| # | Prompt | O que faz |
|---|--------|-----------|
| 1 | Persistência + AppState | Salvar perfil no UserDefaults, criar enum AppState (4 estados), refatorar AppRouter |
| 2 | PlanDiagnosticEngine | Lógica de cálculo local (split, volume, calorias, etc.) com tabelas de decisão |
| 3 | DiagnosticView | Tela de diagnóstico personalizado com cards animados + CTAs |
| 4 | Firebase Setup | Integrar Firebase Auth via SPM, configurar projeto e provedores |
| 5 | AuthService | Serviço de autenticação (Apple + Email), encapsulando Firebase Auth |
| 6 | AuthView + Sign in with Apple | Tela principal de auth com botão Apple nativo |
| 7 | EmailAuthView + Forgot | Fluxo completo de email/senha com validação |
| 8 | SubscriptionManager + PaywallView | RevenueCat SDK, tela de paywall com trial, planos mensal/anual |
| 9 | Feature Gates | Sheets contextuais para features premium dentro do app |
| 10 | Integração final | Conectar tudo no AppRouter, testar fluxo completo (guest/free/premium) |

---

## Notas Técnicas

- **Sign in with Apple** requer Apple Developer Program ($99/ano) para funcionar em device real. Em simulador, funciona com limitações.
- **Firebase Auth gratuito** — email e Apple são ilimitados. Só telefone tem limite (10k/mês).
- O `OnboardingProfile` já é `Codable`, então a persistência é trivial.
- Após a conta criada, o perfil será migrado para SwiftData na Etapa 6 do roadmap geral.
- O modo guest (sem conta) usa o mesmo `MainTabView`, mas com flags que desabilitam funcionalidades de servidor e mostram banners de conversão.
- A geração de ficha com IA acontece **após** criação de conta + assinatura premium, usando o token JWT do Firebase para autenticar no backend próprio.
- **RevenueCat** é o serviço usado para monetização (conforme `guia-swift-senior.md` seção 4). Oferece dashboard de métricas, webhooks, cross-platform e tratamento automático de edge cases. SDK: `https://github.com/RevenueCat/purchases-ios.git`
- **Free trial 7 dias** não é obrigatório (decisão de negócio). A Apple só exige transparência sobre preço, duração e auto-renovação se você oferecer trial.
- **Products e preços** são configurados no App Store Connect + dashboard RevenueCat. O app busca via RevenueCat Offerings em runtime.
- Para testar compras no simulador, usar **StoreKit Testing in Xcode** (arquivo `.storekit` local) — funciona com RevenueCat em modo sandbox.
- **Todos os services devem ter protocolo** para DI e testabilidade (conforme `guia-swift-senior.md`): `AuthServiceProtocol`, `SubscriptionManager` (já usa `ObservableObject`), `PlanDiagnosticEngine`.
- **KeychainManager** (não "KeychainHelper") para dados sensíveis — conforme `guia-swift-senior.md` seção 3.1.
