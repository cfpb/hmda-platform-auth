FROM python:3.5-onbuild

MAINTAINER Hans Keeler <hkeeler@gmail.com>

EXPOSE 5000

CMD ["gunicorn", "-c", "conf/gunicorn.py", "-b", "0.0.0.0:5000", "app:app"]
