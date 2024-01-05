FROM ubuntu:latest
COPY power-image-template.sh /app/
WORKDIR /app
RUN chmod +x power-image-template.sh 
CMD ["sh", "-c", "./power-image-template.sh"]


