FROM ubuntu:latest
COPY power-image-template.sh /app/
WORKDIR /app
RUN chmod +x power-image-template.sh 
CMD ["./power-image-template.sh"]


