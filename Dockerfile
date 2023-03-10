FROM python:3.10-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

RUN useradd mario && groupadd bros

USER mario:bros

CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "app:app" ]