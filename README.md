# nextstory

라이브러리 프로젝트

## 설치

(1) 프로젝트 `pubspec.yaml`을 열어서 `dependencies:` 부분에 아래 코드를 추가

```yaml
dependencies:
  nextstory:
    git:
      url: http://ec2-3-34-185-2.ap-northeast-2.compute.amazonaws.com:8889/troy/library_flutter.git
      ref: 1.2.0
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

(4) 안드로이드 `build.gradle`에 코드 추가

```gradle
dependencies {
    constraints {
        implementation('org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0') {
            because('kotlin-stdlib-jdk7 is now a part of kotlin-stdlib')
        }
        implementation('org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.0') {
            because('kotlin-stdlib-jdk8 is now a part of kotlin-stdlib')
        }
    }
}
```
