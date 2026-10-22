# LEAD.md — тимлид (Никита)

Поверх `tech.md`. Ты тимлид и разработчик: владеешь скелетом, контрактами, CI, `obby/`.

## 1. Порядок сборки скелета (до раздачи задач Алексею)

Это стадия 0 из `tech.md` раздел 16: слайсы S0-1…S0-8, по одному PR на слайс. Пункты ниже ложатся на них по колонке «Где описан».

1. Репозиторий: `rokit.toml`, `wally.toml`, `default.project.json`, `stylua.toml`, `selene.toml`, структура папок из раздела 4 `tech.md`.
2. Branch protection на `main`: только через PR, мёрдж при зелёном CI.
3. CODEOWNERS на общие пути (раздел 11 `tech.md`).
4. CI на PR (без деплоя): `stylua --check`, `selene`, `luau-lsp analyze`, Jest-Lua тесты, `rojo build`.
5. Деплой на мёрдж в `main`: Open Cloud (`rbxcloud`) в тестовый place. Ключи в GitHub Secrets.
6. Каркас: `Bootstrap`, `ServiceLocator`, `Net` + `Contracts` + `RateLimiter`, `Signal`/`Promise`/`Trove` из Wally.
7. `DataService` на ProfileStore + `ProfileSchema` + `Migrations`, с интерфейсом-моком для тестов.
8. Типы: `Profile`, `Creature`, `Net`. Конфиги: `Constants`, `JumpConfig`, `ArenaConfig`.
9. `ui/primitives`: Button, Panel, Label, ListItem, ProgressBar, Modal (React-Lua) + kitchen-sink экран.
10. Заглушки данных: 2 стадии в `StageDefs`, 2 существа в `CreatureDefs`, 1 способность в `AbilityDefs`, 1 `RewardTable`.
11. Тестовая зона в Studio: хаб, 3 чекпоинта, 1 launch pad, 1 kill brick, заглушка портала арены.
12. **Эталонная вертикаль:** касание чекпоинта → сервер валидирует → `ProgressService` → запись в профиль → `ProgressChanged` на клиент → UI. Задеплоена в тестовый place. Это шаблон для всех слайсов.

## 2. Чек-лист «скелет готов» (Алексей не стартует фичи до зелёного)

- [ ] CI зелёный на тривиальном PR
- [ ] `rojo build` собирается, синк в Studio работает
- [ ] `Net` принимает валидный payload и отклоняет мусор (контрактный тест)
- [ ] `DataService` грузит/сохраняет профиль, тест на ошибку стора зелёный
- [ ] UI-примитивы рендерятся в kitchen-sink экране
- [ ] Эталонная вертикаль в `main` и на тестовом place
- [ ] `Rng` и время инжектируются, пример теста с детерминизмом есть
- [ ] Заглушки данных существ/способностей лежат в `shared/Data`

## 3. Замороженные контракты в v1

Схема профиля (раздел 5), Net-контракты (раздел 10), типы `StageDef`/`CreatureDef`/`AbilityDef`/`RewardTable` (раздел 6), сигналы `StageCompleted`, `CreatureGrantedServer`, `MatchEnded`.
Интерфейс для Алексея, который должен быть стабилен с первого дня:
- `CreatureService.grant(player, defId, source): Result<CreatureInstance>`
- `CreatureService.equip(player, instanceId): Result<()>`
- `DataService.getProfile(player): ProfileData?`

## 4. Обработка CONTRACT GAP

Получил блок от Алексея → аппендишь контракт в `tech.md` → бампаешь версию и changelog → при смене схемы профиля добавляешь миграцию → закрываешь issue `contract-change` → сообщаешь Алексею версию.

## 5. Миграции и данные

Только ты. Изменение схемы: бамп `ProfileData.version`, функция в `Migrations.luau`, тест миграции «старый профиль → новый». Алексей миграции не пишет.

## 6. Карта и Studio

Team Create для карты. Закрепи зоны: ты — obby-секции и хаб, Алексей — арена. Правила: код только в git, скрипты в Studio не живут, каждая новая деталь получает тег и атрибуты, не скрипт. Ассеты фиксируй в `assets/SOURCES.md`.

## 7. Чек-лист ревью PR (механический)

- [ ] Нет выдуманных типов и ремоутов, всё из `tech.md`
- [ ] Не тронуты чужие зоны и общие файлы
- [ ] Сервер не доверяет клиенту: payload валидируется, есть rate limit, состояние игрока проверяется
- [ ] Контент добавлен данными, без копипаста скриптов
- [ ] Тесты проверяют критерии приёмки, а не зеркалят код
- [ ] Для выдачи награды/существа есть тест идемпотентности
- [ ] Для каждого remote есть контрактный тест
- [ ] Существа и ассеты оригинальные, источник записан
- [ ] Коммиты и PR по конвенции (английский, `type(scope): summary`)

## 8. Твои задачи как разработчика (стадия 1, obby)

Каждая задача = один слайс = один PR.

1. **Checkpoints + respawn + kill bricks.** Теги `Checkpoint`/`KillBrick`, `CheckpointService`, проверка порядка и дистанции. Тесты: порядок стадий (property-based), отказ при «прыжке через стадии».
2. **Сохранение прогресса.** `ProgressService` пишет `highestStage`/`checkpoint`/`completedStages`, респавн на последнем чекпоинте. Тест: загрузка профиля восстанавливает позицию.
3. **Launch pads.** Тег `LaunchPad`, `LaunchController` (клиент), валидация атрибутов при старте. Тесты: границы `Power`.
4. **MovementValidator.** Лимиты скорости/смещения, откат на чекпоинт. Тесты: нарушение → откат, легитимный запуск → без отката.
5. **JumpPowerCalculator + апгрейды + `JumpBoostPickup`.** Чистая функция, property-based: результат ≤ `MAX_JUMP_POWER`, монотонность по уровню апгрейда.
6. **Контент obby.** Стадии s01–s10 в `StageDefs`, milestone на s05 и s10 с `rewardTableId`. Секции карты через Team Create.
7. **Эмит `StageCompleted`.** Идемпотентный: повторное касание того же чекпоинта не шлёт сигнал повторно. Тест.

## 9. Контрольные точки с Алексеем

- Старт стадии 2 (существа): после слайса 7 (сигнал `StageCompleted` в `main`).
- Старт стадии 3 (арена): после merge `CreatureService.equip` и `InventorySnapshot`.

## 10. Решения через ADR

Новые зависимости, разделение на несколько places, монетизация, смена сетевого слоя → ADR (skill `engineering:architecture`), решение фиксируется в `tech.md`.
