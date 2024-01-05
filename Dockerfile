FROM ubuntu:latest
RUN apk --no-cache add curl ca-certificates
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
COPY power-image-template.sh /app/
WORKDIR /app
RUN chmod +x power-image-template.sh 
CMD ["sh", "-c", "./power-image-template.sh"]


