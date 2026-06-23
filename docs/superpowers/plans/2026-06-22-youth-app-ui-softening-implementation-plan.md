# Youth Learning App UI Softening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ปรับ UX/UI ของแอป Flutter ให้ดูนุ่มขึ้น เป็นมิตรขึ้น และลดความรู้สึกเหมือนการสอบ โดยแตะโครงสร้างเดิมให้น้อยที่สุด

**Architecture:** ใช้วิธี polishing pass บนไฟล์ UI เดิมเป็นหลัก โดยเปลี่ยนเฉพาะข้อความ, visual emphasis, และ feedback state ที่กดดันเกินไป ไม่เพิ่มหน้าใหม่ ไม่เปลี่ยน state model และไม่แตะ data layer นอกจากอ่านข้อความเดิมเพื่อให้ wording สอดคล้องกัน

**Tech Stack:** Flutter, Material 3, Dart, ValueListenableBuilder, Animated UI widgets

---

## File Map

- Modify: `lib/constants/app_text.dart`
  - รวมข้อความหลักของแอป โดยเฉพาะ tagline หน้าแรกและ mission description ที่ยังให้ความรู้สึกเป็นการประเมิน
- Modify: `lib/pages/home_tab.dart`
  - ปรับ hero copy, เพิ่มคำอธิบายใต้ tagline, และ soft section title / CTA ที่หน้าแรก
- Modify: `lib/pages/explore_tab.dart`
  - ปรับ empty state, action labels, และข้อความกำกับ deck ให้ดูเบาและเป็นมิตรขึ้น
- Modify: `lib/pages/law_page.dart`
  - soft wording ของ scenario outcome และ tip โดยคง interaction เดิม
- Modify: `lib/pages/quiz_page.dart`
  - ลด progress cue, ปรับ heading/subheading, ปุ่มดำเนินต่อ, และ completion state ให้เป็นโหมดทบทวน
- Modify: `lib/widgets/question_card.dart`
  - เปลี่ยน feedback จากตัดสินเป็นอธิบาย ลดการเน้นสีแดง และลด visual severity ของตัวเลือกที่ตอบผิด
- Modify: `lib/pages/random_fact_page.dart`
  - ปรับ title, auto-play wording, share feedback, และ action row ให้เป็นโทนเรียนรู้มากขึ้น

## Task 1: เตรียมข้อความกลางและภาษาหลักของแอป

**Files:**
- Modify: `lib/constants/app_text.dart`

- [ ] **Step 1: ปรับ tagline และคำอธิบายภารกิจใน `AppText`**

```dart
class AppText {
  static const String appTitle = 'YouthShield';
  static const String appSubtitle = 'พลังของนักเรียนที่ช่วยเป็นเกราะป้องกันภัยยาเสพติด';
  static const String appSubtitleSupporting =
      'ค่อยๆ เรียนรู้ สังเกต และปกป้องตัวเองกับคนรอบข้างได้ในจังหวะที่สบายใจ';

  static const String mission5 = 'ทบทวนความเข้าใจ';
  static const String mission5Desc = 'ลองคิดตามจากคำถามสั้นๆ เพื่อทบทวนสิ่งที่ได้เรียนรู้';
}
```

- [ ] **Step 2: ตรวจว่าหน้าอื่นยัง import และใช้ค่าคงที่เดิมได้**

Run:

```bash
flutter analyze lib/constants/app_text.dart
```

Expected: ผ่านโดยไม่มี error ใหม่จาก symbol ที่เปลี่ยนชื่อหรือเพิ่มใหม่

- [ ] **Step 3: Commit**

```bash
git add lib/constants/app_text.dart
git commit -m "refactor: soften shared app copy"
```

## Task 2: เกลาหน้าแรกให้ชัด อบอุ่น และชวนสำรวจมากขึ้น

**Files:**
- Modify: `lib/pages/home_tab.dart`
- Uses: `lib/constants/app_text.dart`

- [ ] **Step 1: เพิ่ม supporting copy ใต้ tagline ใน hero banner**

```dart
Text(
  AppText.appSubtitle,
  style: TextStyle(
    fontSize: 13 * state.fontScale,
    color: subTextColor,
    height: 1.5,
  ),
),
const SizedBox(height: 8),
Text(
  AppText.appSubtitleSupporting,
  style: TextStyle(
    fontSize: 12.5 * state.fontScale,
    color: subTextColor.withOpacity(0.92),
    height: 1.6,
  ),
),
```

- [ ] **Step 2: soft section title และ CTA ที่ให้ความรู้สึกเป็นการบ้าน**

```dart
Text('เริ่มต้นจากหัวข้อสำคัญ', ...);
Text('ลองเรียนรู้และทบทวนแบบสบายๆ', ...);

title: 'สุ่มการ์ดความรู้',
desc: 'หยิบเกร็ดสั้นๆ มาอ่านได้ทุกเมื่อ',

title: 'ทบทวนความเข้าใจ',
desc: 'ลองตอบคำถามสั้นๆ เพื่อเช็กสิ่งที่เพิ่งเรียนรู้',

Text('สำรวจต่อในแบบที่คุณสนใจ', ...);
```

- [ ] **Step 3: ลดความแข็งของ hero card shadow โดยไม่เปลี่ยน layout**

```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(isDark ? 0.20 : 0.015),
    blurRadius: 8,
    offset: const Offset(0, 3),
  ),
],
```

- [ ] **Step 4: ตรวจเฉพาะไฟล์หน้าแรก**

Run:

```bash
flutter analyze lib/pages/home_tab.dart lib/constants/app_text.dart
```

Expected: ผ่านโดยไม่มี error ใหม่ และหน้าแรกยัง build ได้

- [ ] **Step 5: Commit**

```bash
git add lib/pages/home_tab.dart lib/constants/app_text.dart
git commit -m "feat: soften home tab messaging"
```

## Task 3: เกลา Explore และ Random Fact ให้สบายตาและเป็นโหมดเรียนรู้

**Files:**
- Modify: `lib/pages/explore_tab.dart`
- Modify: `lib/pages/random_fact_page.dart`

- [ ] **Step 1: ปรับ Explore copy ที่แรงหรือแข็งเกินไป**

```dart
Text('เรื่องน่าสนใจวันนี้: ${_topSuggestedFact.title}', ...);
child: Text('ดูเพิ่ม', ...);
hintText: 'ค้นหาความรู้ที่อยากอ่าน...',

Text('ยังไม่มีการ์ดที่บันทึกไว้', ...);
Text(
  'หากเจอการ์ดที่อยากกลับมาอ่านอีกครั้ง สามารถแตะไอคอนบันทึกไว้ก่อนได้',
  ...
),
Text('เลื่อนดูต่อ', ...);

label: isBookmarked ? 'เก็บไว้แล้ว' : 'เก็บไว้อ่าน';
label: 'สุ่มอีกใบ';
label: 'อ่านแบบเต็ม';
```

- [ ] **Step 2: ลดความแข็งของ search card shadow และ action row emphasis**

```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(isDark ? 0.08 : 0.008),
    blurRadius: 6,
    offset: const Offset(0, 2),
  ),
],
```

- [ ] **Step 3: ปรับ Random Fact ให้หลุดจากโทนเล่นเกมและไปทางเรียนรู้**

```dart
title: Text('เกร็ดความรู้แบบสุ่ม', ...);
tooltip: _isAutoPlaying ? 'หยุดการเปลี่ยนข้อความอัตโนมัติ' : 'เปลี่ยนข้อความอัตโนมัติทุก 8 วินาที';

Text('อัตโนมัติ', ...);
label: isBookmarked ? 'เก็บไว้แล้ว' : 'เก็บไว้อ่าน';
label: 'แชร์ต่อ';

_showSnack('แชร์ความรู้เรียบร้อยแล้ว');
_showSnack('คัดลอก "${fact.title}" ไปยังคลิปบอร์ดแล้ว');
```

- [ ] **Step 4: ตรวจสองหน้าที่แก้**

Run:

```bash
flutter analyze lib/pages/explore_tab.dart lib/pages/random_fact_page.dart
```

Expected: ผ่านโดยไม่มี error ใหม่ และ interaction เดิมยังคงอยู่

- [ ] **Step 5: Commit**

```bash
git add lib/pages/explore_tab.dart lib/pages/random_fact_page.dart
git commit -m "feat: soften exploration and random fact flows"
```

## Task 4: Soft ภาษาหน้ากฎหมายโดยคงสถานการณ์และ flow เดิม

**Files:**
- Modify: `lib/pages/law_page.dart`

- [ ] **Step 1: ปรับ outcome และ tip ให้เป็นเชิงอธิบายมากขึ้น**

```dart
outcomeUnsafe:
    'สถานการณ์นี้เสี่ยงมาก เพราะหากมีการตรวจพบสิ่งผิดกฎหมาย คุณอาจถูกมองว่าเกี่ยวข้องกับการครอบครองได้ แม้จะไม่ได้ตั้งใจก็ตาม',
outcomeSafe:
    'ทางเลือกนี้ช่วยลดความเสี่ยงและปกป้องตัวเองได้ดีกว่า เพราะคุณไม่ได้รับฝากสิ่งของที่ตรวจสอบไม่ได้',
tip:
    'หากไม่แน่ใจว่าสิ่งของคืออะไร การปฏิเสธอย่างสุภาพคือวิธีดูแลตัวเองที่ปลอดภัยกว่า',
```

- [ ] **Step 2: ปรับข้อความสถานการณ์อื่นที่ใช้คำขู่หรือคำฟันธงรุนแรง**

```dart
outcomeUnsafe:
    'หากยอมส่งของให้ผู้อื่น คุณอาจถูกมองว่ามีส่วนร่วมกับการกระทำผิดกฎหมายได้ จึงควรรีบขอความช่วยเหลือจากผู้ใหญ่ที่ไว้ใจได้',
outcomeSafe:
    'การขอความช่วยเหลือทันทีเป็นทางเลือกที่ปลอดภัยกว่า และเปิดโอกาสให้ผู้ใหญ่ช่วยดูแลสถานการณ์ได้เร็วขึ้น',
tip:
    'เมื่อถูกกดดันให้ทำสิ่งผิดกฎหมาย อย่ารับมือคนเดียว การบอกผู้ใหญ่ที่ไว้ใจได้ช่วยลดความเสี่ยงได้มาก',
```

- [ ] **Step 3: ปรับ title ของผลลัพธ์ไม่ให้ตัดสินแรงเกินไป**

```dart
final titleText = isUnsafe
    ? 'ผลที่อาจตามมา (ควรระวัง)'
    : 'ผลลัพธ์ของทางเลือกนี้';
```

- [ ] **Step 4: ตรวจเฉพาะไฟล์กฎหมาย**

Run:

```bash
flutter analyze lib/pages/law_page.dart
```

Expected: ผ่านโดยไม่มี error ใหม่ และ scenario interaction เดิมยังทำงานเหมือนเดิม

- [ ] **Step 5: Commit**

```bash
git add lib/pages/law_page.dart
git commit -m "feat: soften legal scenario wording"
```

## Task 5: เปลี่ยน Quiz จากโหมดสอบเป็นโหมดทบทวน

**Files:**
- Modify: `lib/pages/quiz_page.dart`
- Modify: `lib/widgets/question_card.dart`

- [ ] **Step 1: ปรับ heading และลด progress cue ใน `quiz_page.dart`**

```dart
title: const Text(
  'ทบทวนความเข้าใจ',
  style: TextStyle(fontWeight: FontWeight.w700),
),

Text(
  'ช่วงที่ ${_currentIndex + 1} จาก ${_selectedQuestions.length}',
  style: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  ),
),
Text(
  'ลองคิดและเรียนรู้ไปทีละข้อ',
  style: TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: subTextColor,
  ),
),

LinearProgressIndicator(
  value: (_currentIndex + 1) / _selectedQuestions.length,
  minHeight: 4,
  backgroundColor: isDark ? const Color(0xFF334155) : AppColors.border,
  valueColor: AlwaysStoppedAnimation<Color>(
    (isDark ? AppColors.success : AppColors.primary).withOpacity(0.65),
  ),
),
```

- [ ] **Step 2: ปรับปุ่มและ completion screen ให้สื่อการเรียนรู้ต่อเนื่อง**

```dart
Text(
  _currentIndex == _selectedQuestions.length - 1 ? 'ดูสิ่งที่ได้ทบทวน' : 'ไปต่อ',
  ...
)

const Text('ขอบคุณที่ค่อยๆ ทบทวนไปด้วยกัน', ...);
Text(
  'คุณสามารถย้อนกลับไปอ่านหัวข้อเดิม หรือสุ่มเรียนรู้ต่อได้ทุกเมื่อ',
  ...
),
```

- [ ] **Step 3: ปรับ `question_card.dart` จากโทนตัดสินเป็นโทนอธิบาย**

```dart
color: isDark
    ? const Color(0xFF1E293B)
    : (selectedIndex == correctIndex
        ? AppColors.success.withOpacity(0.035)
        : AppColors.primary.withOpacity(0.035)),

Icon(
  selectedIndex == correctIndex
      ? Icons.lightbulb_rounded
      : Icons.info_outline_rounded,
  color: selectedIndex == correctIndex ? AppColors.success : AppColors.primary,
),

Text(
  selectedIndex == correctIndex ? 'เข้าใจตรงกันแล้ว' : 'มาดูคำอธิบายเพิ่ม',
  ...
),

Text(
  'คำตอบที่ช่วยอธิบายได้ชัดคือ: ${options[correctIndex]}',
  ...
),

text: selectedIndex == correctIndex ? 'สรุปสั้นๆ: ' : 'คำอธิบาย: ',
```

- [ ] **Step 4: ลดความแรงของ state ตัวเลือกที่ตอบผิด**

```dart
if (hasAnswered && isSelected && !isCorrect) {
  cardBorderColor = AppColors.primary.withOpacity(0.45);
  cardBgColor = isDark
      ? const Color(0xFF243244)
      : AppColors.primary.withOpacity(0.08);
  textColor = isDark ? Colors.white : AppColors.textDark;
  trailingIcon = Icons.info_outline_rounded;
}
```

- [ ] **Step 5: ตรวจไฟล์ quiz และ question card**

Run:

```bash
flutter analyze lib/pages/quiz_page.dart lib/widgets/question_card.dart
```

Expected: ผ่านโดยไม่มี error ใหม่ และ flow การตอบ-ดูคำอธิบาย-ไปข้อถัดไปยังเหมือนเดิม

- [ ] **Step 6: Commit**

```bash
git add lib/pages/quiz_page.dart lib/widgets/question_card.dart
git commit -m "feat: soften quiz and feedback experience"
```

## Task 6: ตรวจรวมทั้งรอบและเก็บงานเล็กน้อย

**Files:**
- Modify as needed: `lib/constants/app_text.dart`
- Modify as needed: `lib/pages/home_tab.dart`
- Modify as needed: `lib/pages/explore_tab.dart`
- Modify as needed: `lib/pages/law_page.dart`
- Modify as needed: `lib/pages/quiz_page.dart`
- Modify as needed: `lib/pages/random_fact_page.dart`
- Modify as needed: `lib/widgets/question_card.dart`

- [ ] **Step 1: รัน analyzer รวมเฉพาะไฟล์ที่แตะ**

Run:

```bash
flutter analyze lib/constants/app_text.dart lib/pages/home_tab.dart lib/pages/explore_tab.dart lib/pages/law_page.dart lib/pages/quiz_page.dart lib/pages/random_fact_page.dart lib/widgets/question_card.dart
```

Expected: ไม่มี error ใหม่ในไฟล์ที่แก้

- [ ] **Step 2: ทดสอบการเปิดหน้าหลักแบบ manual**

Run:

```bash
flutter run -d windows
```

Expected:
- Home เปิดได้และ hero มีคำอธิบายเพิ่มใต้ tagline
- Explore เปิดได้และข้อความ empty state / action row อ่านนุ่มขึ้น
- Law เปิดได้และ scenario outcome ไม่ใช้โทนขู่แรงเกินไป
- Quiz ยังตอบคำถามได้ครบ flow เดิม แต่ความรู้สึกเหมือนทบทวนมากกว่าสอบ
- Random Fact เปิดได้และ auto-play / share wording เป็นมิตรมากขึ้น

- [ ] **Step 3: ตรวจ diagnostics หลังแก้จริง**

Use: `GetDiagnostics` on recently edited files

Expected: ไม่มี linter error ใหม่ที่เกิดจากงานรอบนี้

- [ ] **Step 4: Commit**

```bash
git add lib/constants/app_text.dart lib/pages/home_tab.dart lib/pages/explore_tab.dart lib/pages/law_page.dart lib/pages/quiz_page.dart lib/pages/random_fact_page.dart lib/widgets/question_card.dart
git commit -m "chore: polish youth learning app ui copy"
```

## Self-Review

- Spec coverage: ครอบคลุม Home, Explore, Law, Quiz, Question Feedback, Random Fact และการเพิ่มคำอธิบายใต้ tagline ตามสเปก
- Placeholder scan: ไม่มี `TODO`, `TBD`, หรือคำสั่งกว้างๆ ที่ไม่บอกว่าจะเปลี่ยนอะไร
- Type consistency: ใช้ `AppText.appSubtitleSupporting` เป็นชื่อใหม่เพียงจุดเดียว และไม่ได้เปลี่ยน state model หรือ data contract เดิม
