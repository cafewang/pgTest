FROM alpine:latest
RUN echo -e "\
apk add sudo\n\
sudo apk add g++ make libffi-dev openssl-dev\n\
sudo apk add readline-dev\n\
sudo apk add zlib-dev\n\
sudo apk add gdb\n\
" > ~/init
RUN  chmod +x ~/init && ~/init
RUN echo -e "\
cd /postgresql-15.2 && ./configure --enable-debug --enable-cassert --enable-thread-safety CFLAGS='-O0 -g'\n\
make -j 10 && make install -j 10\n\
adduser -s /bin/sh -h /home/postgres -D postgres\n\
mkdir /home/postgres/pgdata\n\
chown postgres:postgres /home/postgres/pgdata\n\
sudo -u postgres -s /bin/sh -c '/usr/local/pgsql/bin/initdb -D /home/postgres/pgdata'\n\
sed -i 's/#listen_addresses = '\''localhost'\''/listen_addresses = '\''\*'\''/g' /home/postgres/pgdata/postgresql.conf\n\
sed -i 's/127\.0\.0\.1\/32/0\.0\.0\.0\/0/g' /home/postgres/pgdata/pg_hba.conf\n\
" > ~/install
COPY postgresql-15.2 /postgresql-15.2
RUN  chmod +x ~/install && ~/install
CMD sudo -u postgres -s /bin/sh -c '/usr/local/pgsql/bin/pg_ctl -D /home/postgres/pgdata start && /usr/local/pgsql/bin/psql'
