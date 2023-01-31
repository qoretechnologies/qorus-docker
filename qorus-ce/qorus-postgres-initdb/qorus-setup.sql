create database omq encoding = 'utf8';
\connect omq;
create user omq password 'omq';
grant create, connect, temp on database omq to omq;
grant all on schema public to omq;
grant select on all tables in schema pg_catalog to omq;

create database omquser encoding = 'utf8';
\connect omquser;
create user omquser password 'omquser';
grant create, connect, temp on database omquser to omquser;
grant select on all tables in schema pg_catalog to omquser;
grant all on schema public to omquser;
