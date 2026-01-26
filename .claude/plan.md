# Theme Structure Refactoring Plan

## Overview
테마 구조를 변경하여 Icon을 하드코딩하는 대신 사용자가 Widget을 제공하고, 각 노드 타입별로 독립적인 테마를 가지도록 리팩토링합니다.

## Changes Summary

### 1. 새로운 테마 클래스 생성

#### 1.1 FolderNodeTheme
- **파일**: `lib/themes/folder_node_theme.dart` (새로 생성)
- **프로퍼티**:
  - `Widget? widget` - folder 아이콘 위젯 (collapsed)
  - `Widget? openWidget` - folder 아이콘 위젯 (expanded)
  - `double width` - 위젯 너비 (기본값: 20.0)
  - `double height` - 위젯 높이 (기본값: 20.0)
  - `EdgeInsets padding` - 위젯 padding (기본값: EdgeInsets.zero)
  - `EdgeInsets margin` - 위젯 margin (기본값: EdgeInsets.zero)
  - `double iconToTextSpacing` - 아이콘-텍스트 간격 (기본값: 8.0)
  - `TextStyle? textStyle` - 텍스트 스타일
- **메서드**: copyWith, lerp, ==, hashCode, toString

#### 1.2 ParentNodeTheme
- **파일**: `lib/themes/parent_node_theme.dart` (새로 생성)
- **프로퍼티**: FolderNodeTheme과 동일
- **메서드**: copyWith, lerp, ==, hashCode, toString

#### 1.3 ChildNodeTheme
- **파일**: `lib/themes/child_node_theme.dart` (새로 생성)
- **프로퍼티**:
  - `Widget? widget` - child 아이콘 위젯
  - `double width` - 위젯 너비 (기본값: 20.0)
  - `double height` - 위젯 높이 (기본값: 20.0)
  - `EdgeInsets padding` - 위젯 padding (기본값: EdgeInsets.zero)
  - `EdgeInsets margin` - 위젯 margin (기본값: EdgeInsets.zero)
  - `double iconToTextSpacing` - 아이콘-텍스트 간격 (기본값: 8.0)
  - `TextStyle? textStyle` - 텍스트 스타일
  - `TextStyle? selectedTextStyle` - 선택된 상태 텍스트 스타일
  - `Color? selectedBackgroundColor` - 선택된 상태 배경색
- **메서드**: copyWith, lerp, ==, hashCode, toString

#### 1.4 ExpandIconTheme
- **파일**: `lib/themes/expand_icon_theme.dart` (새로 생성)
- **프로퍼티**:
  - `Widget? widget` - expand 아이콘 위젯
  - `double width` - 위젯 너비 (기본값: 20.0)
  - `double height` - 위젯 높이 (기본값: 20.0)
  - `EdgeInsets padding` - 위젯 padding (기본값: EdgeInsets.zero)
  - `EdgeInsets margin` - 위젯 margin (기본값: EdgeInsets.zero)
- **메서드**: copyWith, lerp, ==, hashCode, toString

### 2. FlutterFolderViewTheme 수정

#### 2.1 프로퍼티 변경
- **제거**:
  - `FolderViewTextTheme textTheme`
  - `FolderViewIconTheme iconTheme`

- **추가**:
  - `FolderNodeTheme folderTheme`
  - `ParentNodeTheme parentTheme`
  - `ChildNodeTheme childTheme`
  - `ExpandIconTheme expandIconTheme`

- **유지**:
  - `FolderViewLineTheme lineTheme`
  - `FolderViewScrollbarTheme scrollbarTheme`
  - `FolderViewSpacingTheme spacingTheme`
  - `FolderViewNodeStyleTheme nodeStyleTheme`

#### 2.2 팩토리 메서드 업데이트
- `FlutterFolderViewTheme.light()` - 기본 아이콘 사용
- `FlutterFolderViewTheme.dark()` - 기본 아이콘 사용

### 3. NodeWidget 수정

#### 3.1 위젯 빌더 메서드 변경
- `_buildExpandIcon()` 추가
  - expandIconTheme.widget이 null이면 빈 SizedBox 반환
  - null이 아니면 padding/margin 적용한 SizedBox(width, height) 안에 widget 배치

- `_buildNodeIcon()` 추가
  - 노드 타입에 따라 folder/parent/childTheme에서 widget 가져오기
  - folder/parent의 경우 isExpanded에 따라 openWidget/widget 선택
  - null이면 빈 SizedBox 반환
  - null이 아니면 padding/margin 적용한 SizedBox(width, height) 안에 widget 배치

#### 3.2 Row 레이아웃 변경
- 하드코딩된 `Icon()` 제거
- 하드코딩된 `SizedBox(width: 8)` 제거
- `_buildExpandIcon()` + spacing + `_buildNodeIcon()` + iconToTextSpacing + Text

#### 3.3 선택 상태 처리
- child 노드만 selectedBackgroundColor 사용
- child 노드만 selectedTextStyle 사용
- CustomInkWell의 selectedColor를 childTheme.selectedBackgroundColor로 변경

#### 3.4 메서드 제거/수정
- `_getNodeIcon()` 제거
- `_getIconColor()` 제거
- `_getTextStyle()` 수정 - 각 테마에서 textStyle 가져오기

### 4. SizeService 수정

#### 4.1 파라미터 변경
- **제거**:
  - `FolderViewTextTheme textTheme`
  - `double iconSize`
  - `double spacing`

- **추가**:
  - `FolderNodeTheme folderTheme`
  - `ParentNodeTheme parentTheme`
  - `ChildNodeTheme childTheme`
  - `ExpandIconTheme expandIconTheme`

#### 4.2 계산 로직 수정
- `_calculateNodeWidth()` 수정:
  - expandIcon: expandIconTheme.width + expandIconTheme.padding + expandIconTheme.margin
  - nodeIcon: 노드 타입에 따라 각 테마의 width + padding + margin
  - iconToTextSpacing: 각 테마의 iconToTextSpacing
  - textStyle: 각 테마의 textStyle

### 5. FolderView/FolderViewContent 수정

#### 5.1 SizeService 호출 업데이트
- 새로운 파라미터로 변경

### 6. 삭제할 파일
- `lib/themes/folder_view_text_theme.dart`
- `lib/themes/folder_view_icon_theme.dart`

### 7. Export 업데이트
- `lib/themes/folder_view_theme.dart` - export 목록 수정

## Implementation Order

1. 새 테마 클래스 생성 (FolderNodeTheme, ParentNodeTheme, ChildNodeTheme, ExpandIconTheme)
2. FlutterFolderViewTheme 수정
3. NodeWidget 수정
4. SizeService 수정
5. FolderView/FolderViewContent 수정
6. 기존 테마 파일 삭제
7. Export 파일 업데이트

## Breaking Changes
이 변경사항은 기존 API를 완전히 변경하므로 메이저 버전 업데이트가 필요합니다.

사용자는 이제 다음과 같이 테마를 정의해야 합니다:
```dart
FlutterFolderViewTheme(
  folderTheme: FolderNodeTheme(
    widget: Icon(Icons.folder, color: Colors.blue),
    openWidget: Icon(Icons.folder_open, color: Colors.blue),
    width: 20,
    height: 20,
  ),
  childTheme: ChildNodeTheme(
    widget: Icon(Icons.insert_drive_file),
    selectedBackgroundColor: Colors.blue.withOpacity(0.1),
  ),
  // ...
)
```
