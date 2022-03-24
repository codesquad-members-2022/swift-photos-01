# Drawing App

- 단계별로 미션을 해결하고 리뷰를 받고나면 readme.md 파일에 주요 작업 내용(바뀐 화면 이미지, 핵심 기능 설명)과 완성 날짜시간을 기록한다.
- 실행한 화면을 캡처해서 readme.md 파일에 포함한다.

## 작업내역

| 시작날짜   | 번호  | 내용                 | 비고 |
| ---------- | :---- | -------------------- | ---- |
|            |       |                      |      |
|            |       |                      |      |
|            |       |                      |      |
|            |       |                      |      |
|            |       |                      |      |
|            |       |                      |      |
| 2022.03.23 | Setp3 | 동시 이미지 다운로드 |      |
| 2022.03.22 | Step2 | 사진 앨범 접근       |      |
| 2022.03.21 | Step1 | 프로젝트 설정        |      |

------

## [Step3] 동시 이미지 다운로드

### 체크리스트

- [x] Json의 데이터 구조를 파악하고, Model클래스 생성
- [x] Json을 파싱 후 데이터 수 만큼 셀을 제작
- [x] 우선 셀을 보여주고 비동기로딩을 사용하여 이미지 출력
- [x] 다운로드 한 이미지는 캐싱하여 보관하고 있는다
- [x] UILongPressGesture를 사용하여 저장메뉴를 제작
- [x] Save를 누르면 해당 이미지가 사진앨범에 저장되고, Step2에서 만든 옵저버에 응답처리

### 핵심기능

* Json DTO를 제작하여 사용한다
* 데이터 수만큼 Cell을 만들어 보여주고, 비동기적으로 이미지를 불러와 출력한다
* LongPress를 사용하여 Save 메뉴를 띄우고, 누르면 이미지가 저장되고 Toast메세지를 띄운다

### 결과화면

![Simulator Screen Recording - iPhone 13 Pro - 2022-03-24 at 10 38 46](https://user-images.githubusercontent.com/5019378/159846245-bb285c7c-e8bb-4c75-8e4c-2a3614862c2a.gif)

------

## [Step2] 사진앨범 접근

### 체크리스트

- [x] NavigationViewController를 사용하고 타이틀을 Photos로 지정
- [x] 포토앨범을 사용하기 위한 권한 설정
- [x] PHAsset 프레임워크를 사용하여 사진첩의 정보를 가져옴
- [x] 사진을 담기위한 CustomCell제작
- [x] PHCachingImageManager를 사용하여 가져온 사진첩의 정보를 이용하여 이미지를 로드
- [x] PHPhotoLibrary 클래스에 사진보관함 번경 옵저버를 등록

### 핵심기능

* 포토앨범을 사용하기위한 권한을 확인한다
* 사진첩에서 이미지정보를 받아와 비동기적으로 이미지를 로드하여 사진을 보여준다
* 사진보관함에서 어떠한 변경이 일어나면 옵저버로 응답이 온다

### 결과화면

<img src="https://user-images.githubusercontent.com/5019378/159823917-546ebbe0-bd81-4c13-9e73-cd18eed9758e.png" alt="Simulator Screen Shot - iPhone 13 Pro - 2022-03-24 at 10 28 35" style="zoom: 25%;" />
<img src="https://user-images.githubusercontent.com/5019378/159823931-a1764cdb-51eb-4da6-9124-0a6e201d5f83.png" alt="Simulator Screen Shot - iPhone 13 Pro - 2022-03-24 at 10 28 31" style="zoom:25%;" />

------

## [Step1] 프로젝트 설정

### 체크리스트

- [x] 이번주 학습 어떻게 할지 논의
- [x] CollectionView 사용
- [x] 40개의 셀을 만들고 각 셀은 랜덤으로 색을 채움
