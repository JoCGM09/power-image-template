FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl ca-certificates
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
COPY power-image-template.sh /app/
WORKDIR /app
RUN chmod +x power-image-template.sh 
CMD ["sh", "-c", "./power-image-template.sh"]


