## Agent skills

### Issue tracker

Issues live in GitHub Issues for `kihyun1998/flutter_folderview`, managed via the `gh` CLI. Pull requests are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels

Canonical label strings (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) — no overrides. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## 우회 금지 (근본 층에서 고쳐라)

증상이 여기서 보인다고 원인도 여기 있는 건 아니다. 이 패키지는 `just_tooltip` 의 **소비처**이고, 결함 상당수는 상류에 있다. 상류 결함을 여기서 *덮지 마라*. 우회는 ① 상류 버그를 가려 고칠 압력을 없애고, ② 같은 지식을 두 층에 복제해 divergence 씨앗이 되고, ③ 상류의 잘못된 기본값을 영원히 기본값으로 남긴다. **우회하고 싶은 충동 = 멈추고 사용자에게 온다** — 무슨 상황인지 설명하고("상류가 X 라서 여기서 Y 해야 통과, 근본은 상류 문제") 상류를 고칠지 *묻는다*. 혼자 우회하지도, 혼자 상류 이슈만 파고 넘어가지도 마라.

- **우회는 공개 API 로 굳는다. 그 다음엔 못 지운다.** 실증(#42/#47): 라벨 툴팁이 뷰 밖에 그려지는 문제에 `NodeTooltipTheme.anchor` 라는 knob 을 냈고, `0.11.0` CHANGELOG 는 `TooltipAnchor.pointer` 를 *"outside the view entirely once the tree scrolls horizontally"* 의 답으로 팔았다. 진짜 원인은 상류가 클립된 child 의 **보이는 부분**을 타깃하지 않는 것이었고 `just_tooltip 0.4.2` 가 고쳤다. 근본을 안 고쳤다면 `anchor` 는 영원히 "버그 피하는 법" 으로 dartdoc 에 남았을 것이다 — 지금 그것은 "커서 옆을 가리킨다" 는 독립된 기능이다.
- **둘 이상의 소비처가 *독립적으로 같은 우회*에 도달했다면, 그건 상류 기본값이 함정이라는 증거다.** 실증(just_tooltip#33): 이 repo 와 `flutter_table_plus` 가 각각 `TooltipAnchor.pointer` 를 하드코딩하고(table_plus 는 테마 dartdoc 에 *"긴 ellipsized 셀엔 pointer 를 써라"* 라고 적기까지 했다) **그 사이 아무도 상류 이슈를 열지 않았다.** 사람들이 올바른 옵션을 발견한 게 아니라 버그를 발견하고 돌아간 것이다. 자매 패키지를 볼 때(1단계) "같은 답" 인지 "같은 우회" 인지 구분한다.
- **상류 수정은 여기서 실검증한다.** 합성 재현이 통과하는 건 "내가 상상한 시나리오에서 동작한다" 일 뿐이다. 로컬 경로를 물려 **전체 스위트**를 돌린다.
  ```yaml
  # pubspec_overrides.yaml — pubspec.yaml 은 안 건드린다
  dependency_overrides:
    just_tooltip:
      path: ../just_tooltip
  ```
  **가장 강한 증거는 우리가 버그를 기대값으로 박제해둔 테스트가 *깨지는* 것이다** — 우리가 독립적으로 관찰해 고정한 증상이 사라졌다는 뜻이니까. 실증(just_tooltip#34): `tooltip_offscreen_test.dart` 의 `"with the default anchor the tooltip is painted outside the view"` 가 `Expected: > 400.0 / Actual: 170.0` 으로 죽었고 나머지 148 개는 통과 = 회귀 없음. 그 테스트는 지금 `"the default anchor targets the visible part of the label"` 이다 — **깨진 테스트를 뒤집는 것까지가 회수**다(아래). 검증이 끝나면 `pubspec_overrides.yaml` 을 **반드시 지운다** — `.gitignore` 에도 `.pubignore` 에도 없어 그대로 커밋되고 그대로 발행된다.
- **상류가 고쳐지면 우회를 회수한다.** 발행에서 끝내면 상류를 고쳐놓고도 하류는 영원히 우회를 들고 있는다. 제약을 올리고, 손수 중화한 테마 값과 버그를 피하려 고른 옵션을 지우고, 버그를 기대값으로 박제한 테스트를 뒤집는다. **하한도 같이 본다** — 실증(`0.11.0`): `just_tooltip 0.4.2` 를 받으면서 Flutter 하한을 `3.10.0` → `3.13.0` 으로 올려야 했다. `flutter analyze` 도 pub.dev 도 안 잡아준다.
- **우회가 *여전히 옳은* 곳은 남기되 이유를 그 자리 주석에 적는다.** 안 적으면 다음 사람이 우회인 줄 알고 지운다. 실증: `folder_view_content.dart` 의 `_wrapWithRowTooltip` 은 행 툴팁 앵커를 `pointer` 로 못 박고 그 근거를 dartdoc 에 남겼다.

## 작업 flow

*Substantive 변경*(버그 수정·기능 추가·동작 변경)이면 이 8단계로 짠다. 단계를 *생략*하려면 (건너뛰는 게 아니라) *왜 이 변경엔 해당 없는지를 명시*한다 — 조용한 스킵 금지.

괄호 안 실증은 그 단계를 건너뛰었다면 놓쳤을 것이다. 전부 이 repo 에서 실제로 일어났다.

### 1. 이슈 먼저 — 실측 숫자·기각한 대안·부정 결과

측정한 숫자를 이슈에 박고, **기각한 대안과 그 이유**를 함께 적는다. 안 그러면 같은 대안이 다시 제안된다.

- **이슈 본문에 쓴 근거도 실측 대상이다.** 실증(#47): 툴팁이 뷰 밖에 그려지는 원인을 *"라벨이 ellipsize 되어 가용 폭을 다 쓴다"* 고 적었다. 재보니 `didExceedMaxLines == false` 이고 rect 폭 926 == `maxIntrinsicWidth` 926 — **라벨은 잘리지 않았다.** 진짜 조건은 `contentWidth > viewportWidth` 였다. 인과가 거꾸로였고, 그 틀린 문장이 이슈·CHANGELOG·README·dartdoc·테스트 주석 **다섯 곳**에 퍼진 뒤에야 잡혔다.
- **자매 패키지가 이미 답했는지 먼저 본다.** 실증(#44/#45): 행 툴팁 설계로 `TooltipScope` enum 을 제안하고, "행이 뷰포트보다 넓으면 무슨 일이 나는가" 를 측정 과제로 #45 에 열었다. `flutter_table_plus` 는 같은 저자·같은 `just_tooltip` 으로 이미 둘 다 풀어놨다 — `rowTooltipBuilder` + `anchor: pointer`, 그리고 코드 주석에 *"off screen once the table scrolls horizontally"*. #44 를 다시 쓰고 #45 를 닫았다.
- **선행 이슈의 근거가 죽으면 그 이슈도 죽는다.** 실증(#43): `TooltipScope` 를 위한 prefactor 였다. 그 설계를 버리자 정당화가 증발했는데 `ready-for-agent` 라벨은 남아 있었다 — 누가 집으면 그대로 만든다. `not planned` 로 닫고 이유를 적었다.
- **부정 결과도 남긴다.** 실증: `just_tooltip 0.4.2` 의 `interactive` 기본값이 `true` 인지 확인하려 `enableTap: true` mutation 을 넣었다. 아무 테스트도 안 죽었다 — 조상 `GestureDetector` 는 자식 `InkWell` 의 탭을 뺏지 못한다(히트 테스트가 깊이 우선). "위험 없음" 이라는 부정 결과를 테스트 파일 주석으로 남겼다.

**"확인 못 했다" ≠ "없다".** 미확인 사실은 갭이다. 이슈로 surfacing 하거나 사용자에게 묻는다 — 조용히 설계 가정으로 승격시키지 마라.

### 2. 추측 금지 — spike 로 실측한다

**코드를 *읽어서* 얻은 확신은 확신이 아니다.**

- **버리는 프로브 테스트.** 스크래치패드에 쓰고 `test/` 로 복사해 돌린 뒤 지운다. rect·좌표·hover 결과를 `print` 로 뽑는다. 프로브는 버리되 **숫자는 이슈/PR 에 남긴다**. 실증(#42): `anchor: pointer` 가 커서를 따라가는지는 가정이었다. 프로브가 커서 130 / 툴팁 130 (pointer) vs 커서 130 / 툴팁 400 (child) 를 찍었다 — 270px 차이.
- **hover 테스트에는 함정이 셋 있고, 각각 조용히 틀린 값을 낸다.** 전부 이 repo 에서 밟았다.
  1. **`waitDuration` 을 주면** hover intent 를 microtask 로 합치는 상류 로직과 경합해 포인터 위치가 확정되기 전에 show 가 돈다.
  2. **한 `testWidgets` 안에서 hover 를 두 번 이상** 하면 `just_tooltip` 의 registry(패키지 전역 싱글턴)가 두 번째부터 억제한다.
  3. **툴팁 크기를 텍스트에 맡기면** `screenMargin` 클램프가 측정 좌표를 흔든다.
  - 실증(#42): 셋을 동시에 밟아 두 앵커가 **같은 좌표**를 냈다. 서로 동의하는 두 오답이 "일관된 결과" 로 읽혔고, upstream 버그로 신고할 뻔했다. 빠져나온 방법은 추론이 아니라 **upstream 의 `just_tooltip_anchor_test.dart` 를 읽은 것**이다 — 그 하니스가 셋을 모두 피하고 있었다.
  - 실증(#52): 한 테스트 안에서 x 좌표 9 개를 훑고 `x=200 → none` 을 읽어 "행 카드가 행을 못 덮는다" 고 결론지었다. 함정 2 였다. hover 하나당 테스트 하나로 다시 재니 `x=300 → card`. **틀린 실험이 옳은 질문을 던졌지만, 그 결론을 믿었다면 없는 버그를 고쳤을 것이다.**
  - 제약은 `test/widgets/node_tooltip_anchor_placement_test.dart` 헤더에 적혀 있다. 새 hover 테스트를 쓰기 전에 읽는다.
- **측정 맥락을 결론과 함께 옮긴다.** 실증(#52): `NodeLabel` 을 고정 400px `SizedBox` 에 넣고 재면 `Flexible` 이 400 에 걸려 라벨이 **ellipsize 된다**. `FolderView` 안에서는 `contentWidth` 가 라벨에 맞춰 늘어나 **잘리지 않는다**. 같은 문장이 한 파일에선 참이고 다른 파일에선 거짓이다. 맥락을 떼고 문장만 옮긴 것이 오류의 전부였다.
- **upstream 소스를 직접 읽는다.** `~/AppData/Local/Pub/Cache/hosted/pub.dev/<pkg>-<ver>/` 를 `grep`/`sed`. 기억·요약 금지. 실증: `JustTooltip.interactive` 기본값이 `true` 라는 것도, `enableTap` 이 `enableTap == true` 일 때만 `GestureDetector` 를 단다는 것도 소스에서 나왔다. 배포된 버전은 `curl -s https://pub.dev/api/packages/<pkg>`.
- **의존성 제약이 실제로 무엇을 허용하는지 계산한다.** 실증(#47): `just_tooltip: ^0.4.0` 은 `>=0.4.0 <0.5.0` 이라 `0.4.2` 를 **이미 해석한다**. `0.4.2` 가 Flutter `3.13.0` 을 요구하는데 우리 pubspec 은 `>=3.10.0` 을 선언하고 있었다 — pubspec 을 *바꿔서*가 아니라 *안 바꿔서* 거짓말이 되고 있었다.

### 3. 설계 판단은 코드 전에 사용자와 확정

**TDD 는 "무엇이 옳은가" 를 답해주지 않는다.** 기대값을 발명하기 전에 정책을 못 박는다. *결정 유형으로 라우팅*한다.

- **순수 메커니즘**(좌표계·훅 선택·자료구조 — 소스로 도출 가능) → 직접 결정하고 **검증 결과만** 제시.
- **계약·정책**(테스트 seam, 공개 API 표면, 기본값, 동작 변경 허용 여부) → **묻는다.**
  - 실증(#44): 긴 라벨에서 라벨 툴팁이 행을 덮어 카드가 도달 불가해지는 문제를 "문서화" 로 처리할지 "overflow 조건부 모드" 를 넣을지 — red 테스트를 쓰기 전에 물었다.
  - 실증(`RowTooltipTheme`): `surface` 기본값을 `bare()` 로 둘지 chrome 있는 테마로 둘지가 API 표면을 가른다. 기본값을 뒤집으면 `Card` 를 반환하는 호출자가 이중 표면을 얻는다.
- **`/grilling` 으로 설계 트리를 먼저 흔든다.** 실증: example 개선 계획을 grilling 에 넣자 첫 질문에서 *"pub.dev 의 Example 탭은 `example/README.md` 를 렌더링하는데 그게 `flutter create` 템플릿"* 이라는, 계획의 전제를 바꾸는 사실이 나왔다.
- **seam 은 테스트를 쓰기 전에 합의한다.** 실증(#44): `FolderView` 공개 위젯 vs `FolderViewContent` 내부. 전자를 골랐기에 "행이 뷰포트보다 넓다" 케이스를 손으로 흉내내지 않고 진짜로 재현할 수 있었다.

### 4. `/tdd` 로 RED→GREEN 수직 슬라이스

한 번에 하나 — 테스트 하나 → 최소 구현 → 반복.

- **RED 가 정말 RED 인지 본다.** 컴파일 에러도 red 다(실증: `rowTooltipBuilder` 없는 상태에서 `No named parameter`). 다만 컴파일 에러로 죽는 mutation 은 **동작을 검증하지 않는다** — 아래 5 를 본다.
- **red→green 이 아닌 테스트는 그렇게 부른다.** 실증(#44): 라벨 툴팁과 행 카드의 공존은 `just_tooltip 0.4.0` 의 중첩 억제가 공짜로 준다. 우리가 구현할 게 없으므로 이건 **특성화(characterization)** 테스트다. 관찰 없이 단언을 먼저 쓰면 상상한 동작을 검증하게 된다 — 먼저 찍어보고, 그 다음 못 박았다.
- **mutation 전에 커밋한다.** 실증(#52): mutation 을 `git checkout -- <file>` 로 "복원" 했는데 수정이 아직 커밋되지 않아 **HEAD 로 되돌아가 수정 자체가 날아갔다.** `git restore` 는 커밋된 것만 복원한다. wip 커밋으로 안전망을 만든 뒤 mutation 을 돌린다.

### 5. 테스트 신뢰 게이트 — 두 질문은 다르다

**통과하는 테스트는 그 자체로 아무것도 증명하지 않는다.** 커버하는 코드를 되돌렸을 때 **빨개지는지** 본다. 이 repo 는 mutation-check 를 PR 본문에 적는다.

- **부재를 주장하는 테스트는 잘못된 이유로도 통과한다.** 실증(#48): "카드 없는 Node 는 감싸지 않는다" 를 `Key('card')` 의 부재로 단언했다. `null` 가드를 지워 모든 행이 빈 툴팁으로 감싸여도 카드 키는 없으니 초록. `find.ancestor(of: 텍스트, matching: JustTooltip)` 로 **래퍼 자체의 부재**를 단언하도록 바꾸니 잡혔다.
- **같은 키를 여러 곳에 쓰면 이웃이 대신 통과시킨다.** 실증(`RowTooltipTheme`): 빌더가 모든 Node 에 `Key('card')` 를 줬다. 카드는 자기 행 **아래 행 위에** 그려진다(행 y `0..40`, 카드 y `28..88`). 커서를 카드로 옮기면 다음 행의 카드가 떠서 `interactive: false` 인데도 `shown() == true` — **`true`/`false` 두 테스트가 같은 잘못된 이유로 통과**하고 있었다.
- **크기를 재는 위치가 틀리면 아무것도 못 본다.** 실증(`RowTooltipTheme`): `expect(card.size, Size(120,60))` 은 chrome 을 감지하지 못한다. padding 은 빌더가 준 위젯 **바깥**에 생기고 그 위젯 크기는 변하지 않는다. 툴팁이 콘텐츠를 감싸는 `Padding` 의 rect 와 비교해야 잡힌다.
- **프레임워크가 이미 보장하는 것을 테스트하면 영원히 초록이다.** 실증(#51): "행 카드가 탭을 가로막을 수 있다" 는 위험을 가정하고 탭 테스트 셋을 썼다. `enableTap: true` 도, 삼키는 `GestureDetector` 도 아무것도 못 죽였다 — 히트 테스트가 깊이 우선이라 조상은 자식의 탭을 뺏지 못한다. **위험이 실재하는지 확인하기 전에 테스트를 썼다.** 하나만 smoke guard 로 남기고(오직 `AbsorbPointer` 가 죽인다) 나머지는 지우되, **지운 이유를 그 자리에 주석으로 남겼다** — 안 그러면 다음 사람이 같은 걸 다시 쓴다.
- **두 변경을 한 mutation 으로 섞지 마라.** 실증(#50): `just_tooltip` 을 `0.4.0` 으로 되돌리자 `JustTooltipTheme.bare()` 가 없어 **컴파일이 깨졌다**. "배치가 고쳐졌다" 를 검증한 게 아니라 "`bare()` 는 0.4.1+ 전용" 만 확인한 것이다. 테마도 손으로 박은 버전으로 같이 되돌려야 배치 동작만 격리됐다.
- **커버리지는 "무엇을 안 봤는지" 를 알려주지, "본 것이 옳은지" 는 말해주지 않는다.**

### 6. `/code-review`

구현·테스트가 끝나고 릴리스 전에 돌린다. 지적은 고치거나, 안 고치면 *왜 안 고치는지*를 남긴다.

### 7. 정합성 스윕 — 동작을 기술하는 모든 표면

코드만 고치고 끝나는 변경은 없다. 아무도 안 보므로 **명시적으로 훑는다**. 이 repo 에서 실제로 갈라진 표면들:

- **`CHANGELOG.md`** — pub.dev 는 *발행 시점의* CHANGELOG 를 스냅샷으로 박는다. 이미 발행된 버전의 항목을 고치지 말고 새 버전을 연다. 반대로 **미발행 버전은 지금 고칠 수 있다** — 실증: `0.11.0` 의 틀린 인과("ellipsized")를 pub.dev 에 나가기 전에 갈아끼웠다.
- **`README.md`** — 실증(#52): 툴팁 비교표가 라벨 툴팁이 *"the node's icon and label"* 에 붙는다고 적혀 있었다. 아이콘은 그 PR 에서 빠졌다.
- **dartdoc** — pub.dev API 문서로 나간다. 실증(#52·`RowTooltipTheme`): `NodeTooltipTheme.anchor` 와 `FolderView.rowTooltipBuilder` 의 dartdoc 에 각각 틀린 인과와 *"the tooltip draws no background, padding, or elevation"*(이제는 기본값일 뿐 법이 아님)이 남아 있었다.
- **앞선 이슈·PR·CHANGELOG 의 forward reference 회수.** 이 repo 에서 거짓이 된 것들: *"see the follow-up issue"*(존재하지 않았다), *"row-wide tooltips are tracked in #44"*(이후 배포됨), *"turn the label tooltip off to see the card"*(#52 가 뒤집음), *"#41: nested suppression 은 여기서 도달 불가"*(#48 이 도달하게 만듦).
- **example 의 카피와 dartdoc** — 사용자가 읽는 표면이다. 실증(#52): 스위치 부제가 여전히 "카드를 보려면 라벨 툴팁을 끄세요" 라고 안내하고 있었다.
- **`docs/adr/`** — 결정이 뒤집히면 ADR 도 뒤집는다. 새 코드는 ADR-0002(caller owns interaction state), ADR-0004(tooltips are chrome, excluded from scale), ADR-0005(tier theme 필드는 의도적 중복 — 공용 base 로 추출 금지)를 지킨다.
- **`CONTEXT.md` 용어집** — 도메인 용어의 source of truth. `Node` 를 "row" 라 부르지 않는다. "row" 는 **렌더링된 줄**이다.
- **`docs/agents/*.md`** — 실증: `triage-labels.md` 가 다섯 라벨이 존재한다고 선언했으나 레포에는 셋뿐이었다. `needs-triage` 를 달려다 실패했다.
- **`.pubignore`** — `.pubignore` 가 존재하면 pub 은 **git 기반 파일 목록을 끈다.** `.gitignore` 는 더 이상 적용되지 않는다. **pub.dev 아카이브는 한 번 올라가면 내릴 수 없다.**

### 8. 게이트 & PR & 릴리스

CI(`.github/workflows/ci.yml`)는 두 잡을 돌린다.

```
# job: Analyze & test (package)
flutter pub get
dart format --output=none --set-exit-if-changed lib test benchmark
flutter analyze
flutter test --coverage

# job: Analyze (example app)   [working-directory: example]
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

- **`flutter analyze` 통과 ≠ CI 통과.** `dart format --set-exit-if-changed` 는 **별개 게이트**다 — analyze 는 lint 규칙을, format 은 서식 정규형을 본다. 실증(#48): 손으로 줄바꿈한 파일 둘 때문에 두 잡이 모두 떨어졌다. 로컬에서 푸시 전에 돌린다:
  ```
  dart format lib test benchmark && (cd example && dart format .)
  flutter analyze && (cd example && flutter analyze)
  flutter test && (cd example && flutter test)
  ```
- **포맷 검사는 `pub get` 뒤여야 한다.** `dart format` 은 `.dart_tool/package_config.json` 에서 언어 버전을 읽는다. CI 의 주석이 그 이유를 적어두고 있다.
- **example 도 테스트 게이트다** — 잡 이름은 아직 `Analyze (example app)` 이지만 `flutter test` 를 돌린다. 실증(#57): 그 스텝이 없던 시절 `example/test/widget_test.dart` 는 `flutter create` 의 "Counter increments smoke test" 였고, 이 앱에 카운터가 없어 `e5f6353 add example` 이후 **한 번도 통과한 적이 없다.** 아무도 몰랐다 — CI 가 안 돌렸으니까. 지금은 부팅 테스트로 갈아끼우고 스텝을 추가했다.
- **통합 테스트는 CI 에 없다.** 실제 데스크톱 앱을 띄운다. `example/integration_test/` 에만 있으므로 **`cd example` 후** `flutter test integration_test/<file>.dart -d windows`. 한 세션에서 둘을 연달아 돌리면 두 번째가 `Error waiting for a debug connection` 으로 죽는다 — **하나씩** 돌린다.
- **`git status` 의 `M` 이 항상 내용 변경은 아니다.** 실증: `example/*/flutter/generated_plugin_registrant.*` 은 `flutter analyze` 가 재생성하며 EOL 만 바뀐다. `git diff` 는 비어 있다. 커밋 전에 `git diff --ignore-all-space --stat` 로 걸러내고 `git restore` 한다.
- **되돌릴 수 없는 것은 사용자가 실행한다.**
  - `dart pub publish` — pub.dev 는 버전 삭제가 없다(7 일 내 retract 만). 에이전트가 실행하지 않는다. `dart pub publish --dry-run` 이 경고 0 개인지만 확인하고 넘긴다.
  - 배포 전 example 을 띄워 **눈으로** 확인한다: `cd example && flutter run -d windows`. hover 는 에이전트가 대신할 수 없다.
- 브랜치 → `fix(<scope>): …` / `feat(<scope>): …` → PR(`Closes #issue`) → CI 그린 확인 → squash 머지(`--delete-branch`).
- **PR 본문에 mutation-check 결과를 적는다.** 어떤 변이를 넣었고 무엇이 죽었는지. 아무것도 안 죽었다면 그것도 적는다 — 그게 이 repo 에서 가장 값어치 있는 발견이었다(#51).
