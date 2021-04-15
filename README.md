# BreadRoad





## 프로젝트 설명

- tbd



## 아키텍처 및 프레임워크 구조

-----

클린 아키텍처를 모바일 앱 성격에 맞추어 적용하여 크게 Domain, Presentation, Data layer로 분리시킵니다. - [Clean Architecture는 모바일 개발을 어떻게 도와주는가? - (1) 경계선: 계층 나누기](https://medium.com/@justfaceit/clean-architecture%EB%8A%94-%EB%AA%A8%EB%B0%94%EC%9D%BC-%EA%B0%9C%EB%B0%9C%EC%9D%84-%EC%96%B4%EB%96%BB%EA%B2%8C-%EB%8F%84%EC%99%80%EC%A3%BC%EB%8A%94%EA%B0%80-1-%EA%B2%BD%EA%B3%84%EC%84%A0-%EA%B3%84%EC%B8%B5%EC%9D%84-%EC%A0%95%EC%9D%98%ED%95%B4%EC%A4%80%EB%8B%A4-b77496744616)
추후에 레이어별로 프레임워크를 나눌것을 고려하여 접근제한자를 이용합니다.

### Data Layer

- Remote + Data Mapping
- Local(TBD): SQLiteDB, keychain, UserDefault
- Repository implement: 용도에 따라 Remote + Local을 활용


### Domain Layer

- Entity
- Usecase
- Repository(Protocols)
- Common Extensions

### PresentationLayer

- Each Presentations
    - 각 화면은 Rx + MVVM 패턴으로 구성
    - view는 코드로 구성
- CommonPresentation
  - UI Extensions
  - ViewUsecase: 프로토콜 기본구현으로 공통로직 추출?



## 코드 컨벤션

----

- TBD



## Test

------

- view(+viewController)를 제외한 나머지 로직을 테스트하는것이 원칙
- stub 기반의 classic 한 테스트 방식을 이용



## CI/CD

------

- github actions를 이용하고 로컬머신 구축 예정
- 테스트 배포는 TestFlight를 이용



