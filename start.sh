#!/bin/sh
celery -A tasks \
    worker \
    -l debug