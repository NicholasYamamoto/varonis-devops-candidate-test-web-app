FROM python:3.10-slim

WORKDIR /app

COPY . .

RUN useradd mario && groupadd bros

USER mario:bros

RUN sudo pip install --no-cache-dir -r requirements.txt

CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "app:app" ]