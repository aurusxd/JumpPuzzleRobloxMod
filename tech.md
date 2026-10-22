# tech.md — общее ядро проекта

**Версия: v2**
Changelog (append-only, меняет только тимлид, каждое изменение контракта бампает версию):
- v2 — дорожная карта переписана слайсами с ID (S0-1…S5-3), добавлена стадия 0 с зависимостями и гейтом. Контракты не менялись.
- v1 — начальное ядро: стек, структура, схема данных, сетевые контракты, существа, арена, тесты, конвенции.

Читают все: тимлид и Алексей. Подчиняйся дословно. Контракты не выдумывай. Нет нужного контракта → `CONTRACT GAP` (см. раздел 12).

---

## 1. Проект

Рабочее название: **Jumpbound** (проверить на занятость до публикации).
Roblox-игра из трёх частей:

1. **Obby (jump puzzle).** Длинная полоса препятствий со стадиями и чекпоинтами. Трамплины (launch pads), апгрейды силы прыжка, временные бусты.
2. **Существа.** На вехах obby (milestone stages) игрок получает существо. Существа собираются в инвентарь.
3. **PvP-арена.** Игрок берёт одно экипированное существо в арену. Существо даёт статы и активную способность. Бой серверно-авторитетный.

Цель первого релиза (MVP): играбельный obby на ~30 стадий, 8–12 существ, одна арена, сохранение прогресса.

### Правовые правила по существам (обязательны)
Существа **полностью оригинальные**. Не копировать и не «слегка переделывать» Pokémon или любую другую франшизу.
- Концепт: слизни/желе-существа («слаймы») с оригинальной стихийной системой и оригинальными именами.
- Запрещено: названия, силуэты, цветовые схемы и атрибутика чужих франшиз; термины вроде «покебол», «тренер», «эволюция в стиле X»; референсы с чужим IP в промптах для генерации ассетов.
- Все имена существ и стихий придумываем сами, проверяем на совпадения с существующими товарными знаками до публикации.
- Модели/текстуры/звуки: только свои, из Roblox-каталога с разрешённой лицензией или сгенерированные без IP-референсов. Источник каждого ассета записывается в `assets/SOURCES.md`.
- Соблюдать Roblox Community Standards и правила по возрасту/монетизации.

(Это инженерная гигиена, не юридическая консультация. Перед монетизацией показать проект юристу.)

---

## 2. Стек

| Область | Выбор |
|---|---|
| Язык | Luau, `--!strict` в каждом файле |
| Синк с Studio | Rojo 7 |
| Тулчейн | Rokit (версии rojo, wally, stylua, selene, luau-lsp, rbxcloud в `rokit.toml`) |
| Пакеты | Wally (`wally.toml`) |
| Форматирование / линт | StyLua, Selene, `luau-lsp analyze` (strict) |
| Тесты | Jest-Lua (jsdotlua/jest-lua), запуск через `run-in-roblox` или `lune` с моками |
| Данные | ProfileStore (loleris), DataStore под капотом, session locking |
| Сеть | Типизированная обёртка `Net` над RemoteEvent/RemoteFunction + валидация `t` |
| События внутри сервера | `Signal` (GoodSignal), `Promise` (evaera) |
| Очистка ресурсов | `Trove` |
| UI | React-Lua (jsdotlua/react-roblox) |
| Карта | Studio + Team Create. Код только через git/Rojo |
| CI/CD | GitHub Actions; деплой в тестовый place через Open Cloud (`rbxcloud`) |

Один Roblox place на MVP (хаб + obby + арена как зоны в Workspace). Разделение на несколько places — только через ADR.

---

## 3. Принципы кода

**ООП.**
- Классы через единый паттерн: `local Class = {}; Class.__index = Class; function Class.new(...)`, с экспортом типа `export type Class = typeof(setmetatable({}, Class))`.
- Сервисы (`DataService`, `RewardService`...) — синглтоны с явными `Start()` / `Init()` и зависимостями через `Init(deps)`. Без глобального состояния и без `_G`.
- Наследование только там, где реально две и более реализации (`Ability` → `ProjectileAbility`, `AoEAbility`). Иначе композиция.
- Каждый объект с подписками/инстансами имеет `Destroy()` и использует `Trove`.

**DRY.**
- Весь контент — **данные**, не код: стадии, существа, способности, награды лежат в `shared/Data/*`. Новая стадия или существо = новая запись, не новый скрипт.
- Игровые объекты на карте (чекпоинт, трамплин, убивающая деталь) — это **теги CollectionService + атрибуты**, одна реализация на тип. Копипаст скриптов по деталям запрещён.
- Константы и магические числа — только в `shared/Config`.
- Дублирование логики в двух местах → выноси в `shared/Util` или сервис.

**Безопасность (серверная авторитетность).**
- Клиент шлёт только **намерения** (`RequestX`). Результат решает сервер.
- Каждый серверный обработчик remote: проверка типов payload через `t`, проверка состояния игрока (в арене? жив? кулдаун?), rate limit (`RateLimiter`).
- Награды, прогресс, статы, урон — только сервером. Клиентское состояние никогда не пишется в профиль.
- Прогресс obby: сервер принимает чекпоинт, только если он следующий или ниже достигнутого, и игрок физически рядом (проверка расстояния до детали).
- Anti-cheat на скорости/телепорт: `MovementValidator` (раздел 7).
- Выдача награды идемпотентна: ключ `(userId, stageId)` в `claimedRewards`.
- Никаких `loadstring`, `require` по ассет-id, чужих моделей со скриптами без аудита.
- Секретов в клиентских модулях нет. Open Cloud ключи только в GitHub Secrets.
- Покупки (позже): `MarketplaceService.ProcessReceipt` идемпотентен, решение по `PurchaseId`.

---

## 4. Структура репозитория

```
default.project.json
rokit.toml  wally.toml  selene.toml  stylua.toml
CLAUDE.md  tech.md  LEAD.md  DEV_ALEXEY.md  CODEOWNERS
assets/SOURCES.md
src/
  shared/                      -> ReplicatedStorage.Shared
    Config/                    Constants.luau, JumpConfig.luau, ArenaConfig.luau
    Data/                      StageDefs.luau, CreatureDefs.luau, AbilityDefs.luau, RewardTables.luau
    Types/                     Profile.luau, Creature.luau, Net.luau
    Net/                       Contracts.luau, Net.luau
    Util/                      RateLimiter.luau, Rng.luau, Result.luau
  server/                      -> ServerScriptService.Server
    core/                      Bootstrap.server.luau, ServiceLocator.luau
    data/                      DataService.luau, ProfileSchema.luau, Migrations.luau
    obby/                      ProgressService.luau, CheckpointService.luau, JumpPowerCalculator.luau, MovementValidator.luau
    creatures/                 CreatureService.luau, RewardService.luau, InventoryService.luau
    arena/                     ArenaService.luau, MatchStateMachine.luau, DamageCalc.luau, Ability*.luau
  client/                      -> StarterPlayerScripts.Client
    core/                      Bootstrap.client.luau
    obby/                      LaunchController.luau, CheckpointController.luau
    creatures/                 InventoryController.luau
    arena/                     ArenaController.luau, AbilityInput.luau
    ui/                        primitives/, screens/
tests/                         зеркалит src/, файлы *.spec.luau
```

Владение папками — раздел 11.

---

## 5. Схема данных (профиль игрока)

Хранилище: ProfileStore, ключ `Player_<UserId>`. Версионируется полем `version`, миграции в `Migrations.luau` (пишет только тимлид).

```lua
export type CreatureInstance = {
  id: string,            -- uuid, генерит сервер
  defId: string,         -- ключ в CreatureDefs
  level: number,
  xp: number,
  obtainedAt: number,    -- os.time()
  source: string,        -- "stage:<stageId>" | "arena" | "shop"
}

export type ProfileData = {
  version: number,       -- текущая: 1
  obby: {
    highestStage: number,
    checkpoint: string,                 -- stageId последнего чекпоинта
    completedStages: { [string]: true },
    claimedRewards: { [string]: true }, -- ключ stageId, идемпотентность наград
    jumpUpgradeLevel: number,           -- перманентный апгрейд
  },
  creatures: {
    owned: { [string]: CreatureInstance }, -- ключ = instance id
    equipped: string?,                      -- instance id
  },
  stats: {
    arenaWins: number,
    arenaKills: number,
    arenaDeaths: number,
  },
}
```

Правила: новые поля добавляются только через бамп `version` + миграцию + бамп `tech.md`. Дефолты живут в `ProfileSchema.default()`.

---

## 6. Контент-данные (shared/Data)

```lua
export type StageDef = {
  id: string,                 -- "s01".."s30"
  index: number,
  isMilestone: boolean,
  rewardTableId: string?,     -- только у milestone
  checkpointTag: string,      -- имя детали-чекпоинта на карте
}

export type CreatureDef = {
  id: string,
  displayName: string,
  element: "Ember" | "Tide" | "Moss" | "Volt" | "Dust",  -- оригинальные стихии; расширение — через tech.md
  rarity: "Common" | "Rare" | "Epic" | "Legendary",
  baseStats: { hp: number, attack: number, speed: number },
  abilityId: string,
  modelAsset: string,
}

export type AbilityDef = {
  id: string,
  kind: "Projectile" | "AoE" | "Dash" | "Shield",
  cooldown: number,
  damage: number,
  params: { [string]: number },
}

export type RewardTable = {
  id: string,
  entries: { { defId: string, weight: number } },
  guaranteedRarityAtLeast: string?,
}
```

Награда на milestone-стадии: `RewardService.rollFor(player, stageId)` → взвешенный выбор по `RewardTable` через инжектируемый `Rng` (в тестах детерминирован).

---

## 7. Obby: механика

### Стадии и чекпоинты
- Чекпоинт — деталь с тегом `Checkpoint` и атрибутом `StageId`. Реализация одна: `CheckpointService`.
- Касание обрабатывает **сервер** (Touched + проверка расстояния + порядок стадий). Успех → `ProgressService.advance(player, stageId)` → сигнал `StageCompleted(player, stageId)`.
- Респавн игрока на последнем чекпоинте.
- Убивающая деталь: тег `KillBrick`. Одна реализация.

### Сила прыжка (в Roblox это возможно)
- `Humanoid.UseJumpPower = true`. Итоговое значение считает сервер: `JumpPowerCalculator.compute(base, upgradeLevel, activeBoosts)` (чистая функция, покрывается тестами и property-based проверками).
- Параметры в `JumpConfig`: `BASE_JUMP_POWER`, таблица `UPGRADE_STEPS`, `MAX_JUMP_POWER` (жёсткий потолок), `BOOST_DURATION`.
- Перманентный апгрейд: `obby.jumpUpgradeLevel`. Временные бусты (power-up на карте, тег `JumpBoostPickup`): живут в памяти сервера, не в профиле.

### Трамплины (launch pads)
- Деталь с тегом `LaunchPad`, атрибуты `Power` (number), `Direction` (Vector3, опц.). Реализация одна: `LaunchController` на клиенте.
- Почему клиент: персонаж принадлежит клиенту по network ownership, серверный импульс даёт рывки. Клиент применяет `AssemblyLinearVelocity`, сервер **валидирует** результат.
- `MovementValidator` (сервер): лимит скорости `MAX_LAUNCH_VELOCITY + margin`, лимит горизонтального смещения за тик, проверка «игрок не пролетел чекпоинты». Нарушение → телепорт на последний чекпоинт + счётчик подозрений.
- Значения `Power` на картe ограничены `LAUNCH_POWER_MIN/MAX` из `JumpConfig`; сервер при старте проверяет атрибуты всех `LaunchPad` и логирует выход за границы.

---

## 8. Существа и инвентарь

- `CreatureService` — единственная точка выдачи и изменения существ: `grant(player, defId, source)`, `equip(player, instanceId)`.
- `RewardService` слушает `StageCompleted`, на milestone вызывает `rollFor` → `CreatureService.grant`. Идемпотентность: если `claimedRewards[stageId]` уже есть — награда не выдаётся.
- Выдача: сервер генерит `id` (uuid), пишет в профиль, шлёт клиенту `CreatureGranted`.
- Экипированное существо в арене: серверный `ArenaService` читает `equipped` из профиля, клиентскому значению не доверяет.

---

## 9. PvP-арена

- Зона в Workspace (`Workspace.Arena`), вход через портал (тег `ArenaPortal`) → `RequestJoinArena`.
- `MatchStateMachine`: `Lobby → Countdown → Active → Ended → Lobby`. Переходы только серверные, таймеры в `ArenaConfig`.
- Бой серверно-авторитетный: способность запрашивается `ArenaUseAbility`, сервер проверяет кулдаун, жив ли игрок, дистанцию/цель, считает урон `DamageCalc.compute(attackerStats, abilityDef, targetStats)` (чистая функция).
- Существо в бою: даёт статы (hp, attack, speed) и одну активную способность. Пассивки и эволюции — вне MVP.
- Выход из арены/смерть → возврат на последний чекпоинт хаба. Статы `stats.*` обновляет сервер по окончании матча.
- Способности реализованы наследованием от `Ability` (`ProjectileAbility`, `AoEAbility`, `DashAbility`, `ShieldAbility`); новая способность = запись в `AbilityDefs` + при необходимости новый подкласс.

---

## 10. Сетевые контракты (Net)

Все remote объявлены в `shared/Net/Contracts.luau`. Каждый контракт: имя, направление, схема payload (`t`), rate limit.

Client → Server:

| Имя | Payload | Лимит |
|---|---|---|
| `RequestEquipCreature` | `{ instanceId: string }` | 2/с |
| `RequestJoinArena` | `{}` | 1/с |
| `RequestLeaveArena` | `{}` | 1/с |
| `ArenaUseAbility` | `{ targetPosition: Vector3? }` | 10/с |

Server → Client:

| Имя | Payload |
|---|---|
| `ProgressChanged` | `{ stageId: string, highestStage: number }` |
| `CreatureGranted` | `{ instance: CreatureInstance }` |
| `InventorySnapshot` | `{ owned: {[string]: CreatureInstance}, equipped: string? }` |
| `ArenaStateChanged` | `{ state: string, endsAt: number? }` |
| `ArenaHitConfirmed` | `{ attackerId: number, targetId: number, damage: number }` |

Внутренний сервер-шина (Signal, без сети):
- `StageCompleted(player, stageId)`
- `CreatureGrantedServer(player, instance)`
- `MatchEnded(results)`

Новый контракт = только через тимлида (раздел 12).

---

## 11. Владение и границы

| Зона | Владелец |
|---|---|
| `shared/Types`, `shared/Net`, `shared/Config`, `shared/Util`, `data/` (схема, миграции), `core/`, CI, `tech.md` | Тимлид |
| `obby/` (server + client), `shared/Data/StageDefs`, карта obby | Тимлид (как разработчик) |
| `creatures/`, `arena/`, `shared/Data/CreatureDefs`, `AbilityDefs`, `RewardTables`, UI существ и арены, карта арены | Алексей |
| `ui/primitives` | Тимлид |

CODEOWNERS + branch protection: правки `tech.md`, `shared/Types`, `shared/Net`, `shared/Config`, `server/data`, `ui/primitives`, `default.project.json` идут только через ревью тимлида.

Карта: Team Create в Studio, каждая зона (obby-секции, арена, хаб) закреплена за одним человеком. Одновременно одну зону двое не правят. Скрипты в Studio не пишем: код только в git.

---

## 12. Протокол CONTRACT GAP

Не хватает типа/поля/remote/сигнала/стадии:
1. **Стоп.** Не пиши код с выдуманным контрактом.
2. Выдай блок:
```
CONTRACT GAP
Нужно: <что именно>
Зачем: <какая задача блокируется>
Предлагаемая форма: <тип / payload / поле>
```
3. Открой issue с меткой `contract-change`, продолжай на локальной заглушке.
4. Тимлид аппендит контракт в `tech.md`, бампает версию, закрывает issue.

---

## 13. Тесты

Тесты привязаны к слайсу и PR. PR без тестов не проходит гейт.

- Тесты выводятся из **критериев приёмки задачи**, не из реализации.
- **Чистая логика** (`JumpPowerCalculator`, `DamageCalc`, `RewardService.rollFor`, валидация порядка стадий): юнит + property-based (генерация входов, проверка инвариантов: прыжок ≤ `MAX_JUMP_POWER`, урон ≥ 0, вес наград суммируется корректно).
- **Идемпотентность:** `rollFor`/`grant` по одному `(userId, stageId)` дважды → ровно одно существо.
- **Контрактные тесты Net:** каждый remote отклоняет мусорный payload; сервер игнорирует rate-limit нарушителей.
- **Путь ошибки:** `DataService` с мок-ProfileStore, возвращающим `nil` / ошибку; игрок кикается корректно, ничего не пишется.
- **Безопасность:** тесты на `MovementValidator` (нарушение скорости → откат), на «клиент прислал чужой instanceId» → отказ.
- Рандом инжектируется (`Rng`), время инжектируется. Прямых `math.random`/`os.time` в логике нет.

---

## 14. Конвенции коммитов, PR, комментариев

- Язык: только английский (коммиты, PR, комментарии в коде).
- Коммит: `type(scope): summary`. `type` ∈ `feat|fix|test|refactor|chore|docs`. Императив, строчная, без точки, до ~50 символов. Тело только про *почему*.
- Коммить сам по ходу, маленькими логическими коммитами. Каждый коммит по возможности проходит `luau-lsp analyze` и `selene`.
- PR: заголовок краткий + ID задачи; тело короткое: что делает слайс, какие контракты/типы затрагивает, чем покрыт тестами.
- Комментарии объясняют *почему*. Закомментированный код не оставлять.
- Проза без филлеров, активный залог.

---

## 15. Definition of Done (одна задача)

- `stylua --check`, `selene`, `luau-lsp analyze` зелёные.
- Тесты по разделу 13 написаны и зелёные.
- Нет выдуманных типов: всё из `tech.md`.
- Не тронуты чужие зоны и общие файлы.
- Сервер не доверяет клиенту (раздел 3).
- Контент добавлен как данные, а не копипастой скриптов.
- PR привязан к задаче, коммиты по конвенции.

---

## 16. Дорожная карта

Правило: каждая строка = один вертикальный слайс = один PR. Детальное описание слайса (цель, критерии, тесты) лежит в файле роли, колонка «Где описан».
Слайс стартует, когда выполнены его зависимости. Стадия закрывается, когда смёрджены все её слайсы.

### Стадия 0 — скелет (тимлид, гейт для остальных)

| ID | Слайс | Владелец | Зависит от | Где описан |
|---|---|---|---|---|
| S0-1 | Репозиторий, тулчейн, структура, CODEOWNERS, branch protection, CI-гейт на PR | Тимлид | — | LEAD.md §1 п.1–4 |
| S0-2 | Деплой в тестовый place на мёрдж в `main` (Open Cloud) | Тимлид | S0-1 | LEAD.md §1 п.5 |
| S0-3 | `Net` + `Contracts` + `RateLimiter`, `Bootstrap`, `ServiceLocator` | Тимлид | S0-1 | LEAD.md §1 п.6 |
| S0-4 | `DataService` (ProfileStore), `ProfileSchema`, `Migrations`, мок для тестов | Тимлид | S0-1 | LEAD.md §1 п.7 |
| S0-5 | Типы, конфиги, `Rng`, `Result` | Тимлид | S0-1 | LEAD.md §1 п.8 |
| S0-6 | `ui/primitives` + kitchen-sink экран | Тимлид | S0-1 | LEAD.md §1 п.9 |
| S0-7 | Заглушки данных + тестовая зона в Studio | Тимлид | S0-5 | LEAD.md §1 п.10–11 |
| S0-8 | **Эталонная вертикаль:** чекпоинт → прогресс → профиль → клиент | Тимлид | S0-2…S0-7 | LEAD.md §1 п.12 |
| S0-9 | Дизайн-док существ, блокаут арены в Studio, `assets/SOURCES.md` (без кода и контрактов) | Алексей | — | DEV_ALEXEY.md «Старт» |

Гейт: чек-лист «скелет готов» (LEAD.md §2) зелёный целиком. До него Алексей делает только S0-9.

### Стадия 1 — obby core (тимлид)

| ID | Слайс | Зависит от | Где описан |
|---|---|---|---|
| S1-1 | Checkpoints, respawn, kill bricks | Гейт | LEAD.md §8 п.1 |
| S1-2 | Сохранение прогресса | S1-1 | LEAD.md §8 п.2 |
| S1-3 | Launch pads | S1-1 | LEAD.md §8 п.3 |
| S1-4 | `MovementValidator` | S1-3 | LEAD.md §8 п.4 |
| S1-5 | `JumpPowerCalculator`, апгрейды, `JumpBoostPickup` | S1-2 | LEAD.md §8 п.5 |
| S1-6 | Контент obby s01–s10 | S1-1 | LEAD.md §8 п.6 |
| S1-7 | Эмит `StageCompleted` (идемпотентный) | S1-2 | LEAD.md §8 п.7 |

### Стадия 2 — существа (Алексей)

| ID | Слайс | Зависит от | Где описан |
|---|---|---|---|
| S2-1 | Инвентарь и выдача (`CreatureService`) | Гейт | DEV_ALEXEY.md A1 |
| S2-2 | Награды на milestone (`RewardService`) | S2-1, S1-7 | DEV_ALEXEY.md A2 |
| S2-3 | Контент существ и способностей | Гейт, S0-9 | DEV_ALEXEY.md A3 |
| S2-4 | UI существ | S2-1 | DEV_ALEXEY.md A4 |

S2-1 и S2-3 идут параллельно со стадией 1.

### Стадия 3 — арена (Алексей)

| ID | Слайс | Зависит от | Где описан |
|---|---|---|---|
| S3-1 | Матч-стейты, портал, join/leave | Гейт | DEV_ALEXEY.md B1 |
| S3-2 | Бой и способности, `DamageCalc` | S3-1, S2-3 | DEV_ALEXEY.md B2 |
| S3-3 | Статы существа в бою | S3-2, S2-1 | DEV_ALEXEY.md B3 |
| S3-4 | Итоги матча и `stats.*` | S3-2 | DEV_ALEXEY.md B4 |
| S3-5 | UI арены | S3-2 | DEV_ALEXEY.md B5 |
| S3-6 | Карта арены | S0-9 | DEV_ALEXEY.md B6 |

### Стадия 4 — контент и полировка

| ID | Слайс | Владелец | Зависит от |
|---|---|---|---|
| S4-1 | Obby s11–s30, остальные milestone | Тимлид | S1-6 |
| S4-2 | Существа 9–12, новые способности | Алексей | S2-3, S3-2 |
| S4-3 | Звук и VFX (obby + арена) | Каждый свою зону | S1-6, S3-5 |
| S4-4 | Балансировка: сила прыжка, веса наград, урон | Тимлид | S4-1, S4-2 |

### Стадия 5 — релизная подготовка

| ID | Слайс | Владелец | Зависит от |
|---|---|---|---|
| S5-1 | Аудит ассетов и IP по `assets/SOURCES.md` | Оба | S4-3 |
| S5-2 | Нагрузочный прогон (арена на максимум игроков, DataStore) | Тимлид | S4-4 |
| S5-3 | Монетизация (отдельный ADR перед стартом) | Тимлид | S5-1 |
