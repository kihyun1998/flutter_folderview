# Lessons — flutter_folderview 실증

이 repo 가 변경 작업의 각 단계에서 실제로 **무엇을 놓쳤나** 의 기록 — 규칙에 무게를
주는 근거. 전부 이 repo 에서 실제로 일어났다. 단계 제목은 사건을 묶는 분류일 뿐이다.
사건이 가리키는 영역·불변식은 [`docs/map/`](../map/README.md) 에 있다. 새 실증은 해당 단계 밑에.

---

## Step 1 — 이슈 먼저 (실측·기각 대안·부정 결과)

- **#47 (본문 근거도 실측 대상, 인과가 거꾸로)**: 툴팁이 뷰 밖에 그려지는 원인을 *"라벨이
  ellipsize 되어 가용 폭을 다 쓴다"* 고 적었다. 재보니 `didExceedMaxLines == false`, rect 폭
  926 == `maxIntrinsicWidth` 926 — **라벨은 잘리지 않았다.** 진짜 조건은 `contentWidth >
  viewportWidth`. 틀린 문장이 이슈·CHANGELOG·README·dartdoc·테스트 주석 **다섯 곳**에 퍼진
  뒤에야 잡혔다.
- **#44/#45 (자매 패키지가 이미 답했는지 먼저)**: 행 툴팁으로 `TooltipScope` enum 을
  제안하고 "행이 뷰포트보다 넓으면?" 을 #45 에 측정 과제로 열었다. `flutter_table_plus` 가
  같은 저자·같은 `just_tooltip` 으로 이미 둘 다 풀어놨다 — `rowTooltipBuilder` +
  `anchor: pointer`. #44 를 다시 쓰고 #45 를 닫았다.
- **#43 (선행 근거가 죽으면 이슈도 죽는다)**: `TooltipScope` prefactor 였다. 설계를 버리자
  정당화가 증발했는데 `ready-for-agent` 라벨이 남아 있었다 — 누가 집으면 그대로 만든다.
  `not planned` 로 닫고 이유를 적었다.
- **부정 결과**: `interactive` 기본값이 `true` 인지 확인하려 `enableTap: true` mutation 을
  넣었다. 아무 테스트도 안 죽었다 — 조상 `GestureDetector` 는 자식 `InkWell` 의 탭을 못
  뺏는다(히트 테스트 깊이 우선). "위험 없음" 을 테스트 주석으로 남겼다.

## Step 2 — spike 로 실측 (hover 함정 셋)

- **#42 (프로브 숫자)**: `anchor: pointer` 가 커서를 따라가는지는 가정이었다. 프로브가 커서
  130 / 툴팁 130(pointer) vs 130 / 400(child) 를 찍었다 — 270px 차이.
- **hover 테스트 함정 셋 (각각 조용히 틀린 값)**: ① `waitDuration` 은 상류의 microtask
  hover-intent 합치기와 경합, ② 한 `testWidgets` 안 hover 두 번은 registry(전역 싱글턴)가
  억제, ③ 텍스트 크기 툴팁은 `screenMargin` 클램프가 좌표를 흔듦. **#42**: 셋을 동시에 밟아
  두 앵커가 **같은 좌표**를 냈고, 서로 동의하는 두 오답이 "일관된 결과" 로 읽혀 upstream
  버그로 신고할 뻔했다. 탈출은 추론이 아니라 **upstream `just_tooltip_anchor_test.dart` 를
  읽은 것** — 그 하니스가 셋을 모두 피한다.
- **#52 (틀린 실험이 옳은 질문을)**: 한 테스트에서 x 9 개를 훑어 `x=200 → none` 을 읽고
  "행 카드가 행을 못 덮는다" 고 결론지었다(함정 2). hover 하나당 테스트로 재니 `x=300 →
  card`. 그 결론을 믿었다면 없는 버그를 고쳤을 것이다.
- **#52 (맥락을 결론과 함께 옮긴다)**: `NodeLabel` 을 고정 400px `SizedBox` 에 넣으면
  `Flexible` 이 걸려 ellipsize 되지만, `FolderView` 안에선 `contentWidth` 가 라벨에 맞춰
  늘어 잘리지 않는다. 같은 문장이 한 파일에선 참, 다른 파일에선 거짓 — 맥락을 뗀 게 오류.
- **#75 (프로브가 잴 상태를 지웠다)**: preview frame 안의 툴팁 위치를 재려고 `PreviewStage` 를
  tight `SizedBox(1400×900)` 에 넣었다. desktop·tablet·mobile 세 폭이 전부 frame 1400×900
  으로 나왔다 — tight 제약이 `SizedBox.fromSize(spec.size)` 를 덮어써 **폭이 하나도 안 바뀐 채**
  "세 폭 모두 contained" 를 찍은 것. 실제 `ShellPage` 로 뷰포트 막대를 눌러 다시 재니 frame 이
  1008×630 / 606×808 / 373×808 로 갈렸고, mobile 좌우에서 깜빡임(`T-T-…`)이 나왔다. **잰
  상태가 만들어졌는지(frame 크기 == spec)를 먼저 단언한다.**
- **#75 (대조군이 귀속을 가른다)**: 그 깜빡임을 셸 탓으로 적을 뻔했다. 셸 없는 390 폭
  `MaterialApp` 대조군이 똑같이 깜빡였다 — 양옆에 자리가 없으면 클램프된 툴팁이 커서를 덮어
  hover 가 끊겼다 이어진다. 원인은 상류 배치이고 셸이 아니다.
- **#47 (제약 계산)**: `^0.4.0` 은 `0.4.2` 를 이미 해석하고, `0.4.2` 는 3.13 을 요구하는데
  pubspec 은 `>=3.10.0` 을 선언했다 — pubspec 을 *안 바꿔서* 거짓말이 됐다.

## Step 3 — 설계 판단 코드 전에

- **#44 (계약·정책 → 묻는다)**: 긴 라벨에서 라벨 툴팁이 행을 덮어 카드가 도달 불가해지는
  문제를 "문서화" 로 할지 "overflow 조건부 모드" 로 할지 — red 전에 물었다.
- **`RowTooltipTheme` (기본값이 API 표면을 가른다)**: `surface` 기본을 `bare()` 로 둘지
  chrome 테마로 둘지가 표면을 가른다 — 뒤집으면 `Card` 반환 호출자가 이중 표면을 얻는다.
- **grilling 이 전제를 뒤집음**: example 개선 계획을 넣자 첫 질문에서 *"pub.dev Example 탭은
  `example/README.md` 를 렌더 = `flutter create` 템플릿"* 이라는 전제-파괴 사실이 나왔다.
- **#44 (seam 은 테스트 전에 합의)**: `FolderView` 공개 vs `FolderViewContent` 내부 —
  전자를 골라 "행이 뷰포트보다 넓다" 를 손으로 흉내 안 내고 진짜 재현했다.

## Step 4 — RED→GREEN

- **#44 (특성화 테스트)**: 라벨 툴팁 + 행 카드 공존은 `0.4.0` 중첩 억제가 공짜로 준다 —
  구현할 게 없으므로 특성화 테스트다. 관찰 없이 단언 먼저 쓰면 상상한 동작을 검증한다.
- **#52 (mutation 전 커밋)**: mutation 을 `git checkout -- <file>` 로 "복원" 했는데 수정이
  아직 커밋 안 돼 **HEAD 로 되돌아가 수정 자체가 날아갔다.** `git restore` 는 커밋된 것만
  복원한다 — wip 커밋으로 안전망을 만들고 mutation 을 돌린다.

- **#75 (mutation 이 안 들어갔는데 "결과" 가 나왔다)**: 여러 줄 anchor 를 `grep -cF` 로
  "정확히 한 번" 확인했다. `-F` 는 패턴의 줄마다 **별개 OR 패턴**으로 읽어, 개수 검사가
  무의미했고 치환은 조용히 실패했다 — 원본 프로브가 그대로 다시 돌아 초록을 찍었다. 여러 줄
  mutation 은 Edit 도구로 넣고, 바뀐 줄을 grep 으로 확인한 뒤 돌린다.

## Step 5 — 테스트 신뢰 게이트

**통과하는 테스트는 아무것도 증명하지 않는다** — 커버하는 코드를 되돌려 빨개지는지 본다.
mutation-check 를 PR 본문에 적는다.

- **#48 (부재 주장은 잘못된 이유로도 통과)**: "카드 없는 Node 는 안 감싼다" 를 `Key('card')`
  부재로 단언했다. `null` 가드를 지워 모든 행이 빈 툴팁으로 감싸여도 카드 키는 없으니 초록.
  `find.ancestor(of: 텍스트, matching: JustTooltip)` 로 **래퍼 자체의 부재**를 단언하니 잡혔다.
- **`RowTooltipTheme` (같은 키를 이웃이 대신 통과시킴)**: 빌더가 모든 Node 에 `Key('card')`
  를 줬다. 카드는 자기 행 아래 행 위에 그려진다(행 y0–40, 카드 y28–88). 커서를 카드로 옮기면
  다음 행 카드가 떠서 `interactive: false` 인데도 `shown() == true` — `true`/`false` 두
  테스트가 같은 잘못된 이유로 통과했다.
- **`RowTooltipTheme` (재는 위치가 틀리면 못 본다)**: `expect(card.size, Size(120,60))` 은
  chrome 을 감지 못한다 — padding 은 빌더 위젯 **바깥**에 생기고 그 크기는 안 변한다.
  콘텐츠를 감싸는 `Padding` 의 rect 와 비교해야 잡힌다.
- **#51 (프레임워크 보장하는 것 테스트 = 영원 초록)**: "행 카드가 탭을 가로막을 수 있다" 를
  가정하고 탭 테스트 셋을 썼다. `enableTap: true` 도 삼키는 `GestureDetector` 도 아무것도 못
  죽였다 — 히트 테스트가 깊이 우선이라 조상은 자식 탭을 못 뺏는다. 위험이 실재하는지 확인
  *전에* 테스트를 썼다. 하나만 smoke guard(오직 `AbsorbPointer` 가 죽인다)로 남기고 나머지는
  **지운 이유를 그 자리에 주석으로** 남겼다.
- **#50 (두 변경을 한 mutation 에 섞지 마라)**: `just_tooltip` 을 `0.4.0` 으로 되돌리자
  `JustTooltipTheme.bare()` 가 없어 컴파일이 깨졌다 — "배치가 고쳐졌다" 가 아니라 "`bare()`
  는 0.4.1+ 전용" 만 확인한 것. 테마도 손으로 박은 버전으로 같이 되돌려야 배치만 격리된다.

## Step 6/7 — 정합성 스윕 & 게이트

- **#52 (표면 드리프트)**: README 툴팁 비교표가 라벨 툴팁이 *"the node's icon and label"* 에
  붙는다고 적었으나 아이콘은 그 PR 에서 빠졌다. example 스위치 부제도 여전히 "카드를 보려면
  라벨 툴팁을 끄세요" 라고 안내했다. dartdoc 의 *"draws no background…"* 는 이제 법이 아니라
  기본값일 뿐이다.
- **forward reference 회수**: "see the follow-up issue"(없었다), "#44 에서 추적"(배포됨),
  "라벨 툴팁을 끄면 카드가 보인다"(#52 뒤집음), "#41: 중첩 억제 도달 불가"(#48 이 도달하게 함).
- **#48 (format 은 analyze 와 별개 게이트)**: 손으로 줄바꿈한 파일 둘 때문에 두 잡이 모두
  떨어졌다. `dart format --set-exit-if-changed` 는 서식 정규형을, analyze 는 lint 를 본다.
- **example 카운터 smoke test**: `flutter create` 의 "Counter increments" 가 이 앱엔 카운터가
  없어 example 추가 이후 **한 번도 통과한 적이 없다.** example 잡이 `analyze` 만 돌려 아무도
  몰랐고, #57 이 그 테스트를 지우며 `Test` 스텝을 넣었다. **돌지 않는 테스트는 테스트가 아니다.**
- **통합 테스트는 하나씩** — 한 세션에서 둘을 연달아 돌리면 두 번째가 `Error waiting for a
  debug connection`. `generated_plugin_registrant.*` 의 `M` 은 EOL 만 바뀐 것(`git diff
  --ignore-all-space` 로 걸러 `git restore`).
- **#92 (PR 이 싣는 것은 로컬 diff 가 아니다)**: #75 브랜치를 로컬 `main` 에서 땄는데, 그
  `main` 에 push 안 된 커밋 셋(지도 구축·0.11.3 수정·주석 정책)이 있었다. PR 은 `origin/main`
  대비라 52 파일을 실었고 #75 몫은 18 이었다. 본문은 로컬 `main` 대비 diff 만 보고 *"`lib/`
  unchanged"* 라 적었다 — 거짓이었다(0.11.3 수정이 `lib/` 를 바꿨다). squash 는 그 셋의 메시지를
  `feat(example)` 하나로 덮었다. **브랜치를 따기 전에 `git log origin/main..main` 이 비었는지,
  PR 본문을 쓰기 전에 `gh pr view --json files` 의 개수가 내 diff 와 같은지 본다.**
