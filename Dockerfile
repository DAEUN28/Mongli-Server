FROM swift:latest
MAINTAINER DAEUN28

COPY . /Mongli-Server

RUN apt-get update
RUN apt-get install -y libcurl4-openssl-dev libssl-dev 
RUN apt-get install -y libmysqlclient-dev

WORKDIR /Mongli-Server
EXPOSE 8080
CMD swift run -c release -Xcc -I/usr/include/mysql/
