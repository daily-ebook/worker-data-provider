FROM python:3.5-slim
MAINTAINER crisbal cristian@baldi.me

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

#we do this because we can't run worker as root
RUN groupadd worker && useradd --create-home --home-dir /worker -g worker worker
WORKDIR /worker

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y curl wget 

# celery requirements, pretty stable
ADD requirements.txt .
RUN pip install -r requirements.txt

# newspaper requirements, should not change much
RUN apt-get install -y python-dev \
    libxml2-dev \
    libxslt-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng12-dev 
RUN pip install newspaper3k==0.1.7
RUN curl https://raw.githubusercontent.com/codelucas/newspaper/master/download_corpora.py \
    | python

# system ded requirements, less stable than newspaper3k
WORKDIR /tmp
RUN wget https://github.com/jgm/pandoc/releases/download/1.17.2/pandoc-1.17.2-1-amd64.deb -O /tmp/pandoc.deb \
    && dpkg -i /tmp/pandoc.deb \
    && apt-get install -f
RUN apt-get install -y calibre

# python ded requirements, very variable
WORKDIR /worker
ADD ded/requirements.txt ded_requirements.txt
RUN pip install -r ded_requirements.txt

#all other files, very very variable
ADD . .

USER worker

ENTRYPOINT ["celery"]
CMD ["-A", "tasks", "worker", "-l", "debug"]