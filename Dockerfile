FROM ubuntu:16.04

USER root

ENV PG_VERSION 9.6

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get -y update && apt-get install -y wget

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get -y update && apt-get install -y postgresql-$PG_VERSION

USER postgres

RUN /etc/init.d/postgresql start &&\
    psql -a -f scheme.sql &&\
    /etc/init.d/postgresql stop


RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/$PGVER/main/pg_hba.conf

RUN echo "listen_addresses='*'" >> /etc/postgresql/$PGVER/main/postgresql.conf

USER root

RUN wget "https://dl.google.com/go/go1.10.linux-amd64.tar.gz"
RUN tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz &&\
mkdir go && mkdir go/src && mkdir go/bin && mkdir go/pkg

ENV GOPATH $HOME/go/db_forum
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH &&\
export PATH=$PATH:/usr/local/go/bin

ADD ./src $GOPATH/src/
EXPOSE 5000
WORKDIR $GOPATH/src/goExample

CMD service postgresql start && go build github.com/pdmitrya/goExample && ./goExample