FROM python:3.5-slim
MAINTAINER crisbal cristian@baldi.me

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y curl wget

#we do this because we can't run worker as root
RUN groupadd worker && useradd --create-home --home-dir /worker -g worker worker
WORKDIR /worker

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

# python ded requirements, very variable
WORKDIR /worker
ADD ded/requirements.txt ded_requirements.txt
RUN pip install -r ded_requirements.txt

USER worker

#all other files, very very variable
ADD . .

ENTRYPOINT ["celery"]
CMD ["-A", "tasks", "worker", "-l", "debug"]