FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ src/
COPY tests/ tests/

EXPOSE 5000

ENV FLASK_APP=src/hello.py
ENV FLASK_RUN_HOST=0.0.0.0

CMD ["flask", "run"]
