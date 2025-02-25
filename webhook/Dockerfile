FROM python:3.9-slim
WORKDIR /app
COPY webhook.py /app/
RUN pip install flask requests
CMD ["python", "webhook.py"]