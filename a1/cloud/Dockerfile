FROM ubuntu:18.04

RUN mkdir /code
WORKDIR /code

COPY entry-point.sh ./
RUN ["chmod", "+x", "/code/entry-point.sh"]
ENTRYPOINT [ "/code/entry-point.sh" ]