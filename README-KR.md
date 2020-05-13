# 몽리: 꿈을 꾸는 동안-서버

![](https://user-images.githubusercontent.com/45457678/70604680-66691680-1c3c-11ea-9956-d5d4afc98d18.png)

Kitura를 사용한 서버입니다.



## App Features

- REST API



## Technologies

- [Kitura](https://www.kitura.io)
- [SwiftKueryMySQL](https://github.com/IBM-Swift/SwiftKueryMySQL)
- [HeliumLogger](https://github.com/IBM-Swift/HeliumLogger)
- [Swift-JWT](https://github.com/IBM-Swift/Swift-JWT)
- AWS-EC2
- AWS-RDS
- Docker([mongli image](https://hub.docker.com/repository/docker/daeun28/mongli/general))
- https



## Getting Started

몽리는 🌱새싹🌱 개발자들을 위한 개인프로젝트입니다. 그러니 제 코드를 마음껏 사용하셔도 좋습니다. 코드에 대한 질문도 자유롭게 해주세요!!

[API 문서](https://acone1128.gitbook.io/mongli-while-dreaming/)를 보고 간단한 CRUD 서버를 구현해보세요! 간단한 기능이기 때문에 누구나 공부하기 좋습니다😃 

몽리는 [노션](https://www.notion.so/mongli/Mongli-while-dreaming-73d75833c8b44438911e7e360e5cb8b6)에서 관리 되고있습니다. 많은 정보들이 노션에 있으니 방문하셔서 더 많은 정보를 얻으세요.

API는 2021년 5월 5일까지 사용가능합니다😎



#### JWT 사용

JWT사용을 위해서 비밀키가 필요합니다. 터미널에 다음 명령어를 입력하면 비밀키를 만들 수 있습니다.

```
$ ssh-keygen -t rsa -b 4096 -m PEM -f privateKey
```



#### Mysql 포트 변경

SwiftKueryMySQL에서는 Mysql의 기본포트인 3306의 사용을 지양하는 것을 권장합니다. 다음 [링크](https://daeun28.github.io/삽질일기/post13/)에서 포트를 변경하는 방법을 소개합니다.



## Contribution

서버 개발은 처음이라 코드가 많이 부족합니다😅 추후 리팩토링 예정이니 너그럽게 봐주시고 많은 기여 부탁드립니다❣️ 



## License

MIT License. See [LICENSE](https://github.com/DAEUN28/Mongli-Server/blob/master/LICENSE).
