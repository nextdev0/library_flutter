# library_flutter

Flutter 라이브러리 프로젝트

## 설치

(1) 프로젝트 `pubspec.yaml`을 열어서 `dependencies:` 부분에 아래 코드를 추가

```yaml
dependencies:
  nextstory:
    git:
      url: https://github.com/nextdev0/library_flutter.git
      ref: 1.2.7
```

(2) `pub get` 실행

(3) 아래 초기화 코드 추가

```dart
import 'package:flutter/material.dart';
import 'package:nextstory/nextstory.dart';

void main() {
  runApp(
    const LibraryInitializer(
      child: MaterialApp()
    ),
  );
}
```

(4) 안드로이드 `app/build.gradle`에 코드 추가

```gradle
dependencies {
  // ...

  implementation platform("org.jetbrains.kotlin:kotlin-bom:$kotlinVersion")
  implementation 'org.jetbrains.kotlin:kotlin-stdlib'
  implementation 'androidx.core:core-ktx:1.12.0'

  constraints {
    // noinspection ForeignDelegate
    implementation 'org.jetbrains.kotlin:kotlin-stdlib-jdk7'

    // noinspection ForeignDelegate
    implementation 'org.jetbrains.kotlin:kotlin-stdlib-jdk8'
  }
}
```
