# [iOS] 프로젝트명: Clean-Mooyaho, 서비스 이름: Reamind





## 프로젝트 설명

- ~~유저가 무야호를 외칠 수 있는 앱을 만들자를 제외하고는 구체적인게 없는 프로젝트~~

- 읽기목록, 볼 목록 등 인터넷 링크를 관리해주는 앱

- [서비스 기획 v0.1](/docs/무야호_v0.1.md)

- [서비스 기획 v2](/docs/서비스기획v2.md)

  


## 아키텍처 및 프레임워크 구조

클린 아키텍처를 모바일 앱 성격에 맞추어 적용하여 크게 Domain, Presentation, Data layer로 분리시킵니다. - [Clean Architecture는 모바일 개발을 어떻게 도와주는가? - (1) 경계선: 계층 나누기](https://medium.com/@justfaceit/clean-architecture%EB%8A%94-%EB%AA%A8%EB%B0%94%EC%9D%BC-%EA%B0%9C%EB%B0%9C%EC%9D%84-%EC%96%B4%EB%96%BB%EA%B2%8C-%EB%8F%84%EC%99%80%EC%A3%BC%EB%8A%94%EA%B0%80-1-%EA%B2%BD%EA%B3%84%EC%84%A0-%EA%B3%84%EC%B8%B5%EC%9D%84-%EC%A0%95%EC%9D%98%ED%95%B4%EC%A4%80%EB%8B%A4-b77496744616)


### Domain Layer(Domain.framework)
- Entity: 서비스 구현에 필요한 데이터들을 모델링한 객체
- Usecase: 서비스 구현을 위해 모델링한 객체를 다루는 비즈니스로직 및 정책 구현
- Repository(Protocols)
- Common Extensions


### Data Layer(DataStore.framework)
: Domain.framework를 의존 및 이에 정의된 Entity를 관리(조회 및 저장 등)하는 역할
- Remote
- Local: [sqlite](https://github.com/sudopark/SQLiteService) + user defaults + keychain
- Repository implement: 용도에 따라 Remote + Local을 활용

#### FirebaseService.framework

- 파이어베이스 기본 세팅 및 대부분의 Remote 구현 + data mapping

### PresentationLayer

- Presentations
    - 각 화면은 Rx + MVVM 패턴으로 구성 -> [MVVM+Router Template](https://github.com/sudopark/MVVM-Router-Template)로 Scene Module
    - view는 코드로 구성
- CommonPresentation
  - UI Extensions + 재사용 가능한 공통 컴포넌트 및 화면
  - ViewUsecase: presentation layer에서 재사용되어야하는 주요 로직들




## Test

- UI 레벨에서는 viewModel을, 그 외 레이어에서는 모든 로직에 대한 유닛 테스트를 작성하는것이 원칙
- 프레임워크로 분리된 PresentationLayer에 해당하는 화면들의 테스트타겟들은 UsecaseDouble의 테스트 더블들을 이용
- 테스트시 가능한 테스트하려는 대상의 공개 인터페이스를 이용해 테스트
- stub 기반의 테스트 방식을 이용



## 의존관리

- 의존 주입 방식은 생성자 주입을 이용 + 구체타입 생성은 DIContainers에서 관리
- Firebase는 프로젝트에 바로 임베딩 시킴 -> FirebaseService.framework
- 그 외 필요한 서비스는 필요한 framework에서 spm으로 관리




## 코드 컨벤션
- 프로토콜에 Protocol이나 Interface suffix는 제거 -> 구체타입에 Imple suffix 추가



## CI/CD

- CI는 github actions를 이용
- 테스트 배포는 TestFlight를 이용



