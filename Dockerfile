FROM openjdk:17-jdk-slim
WORKDIR /app

COPY HelloWorld.java /app/

RUN javac HelloWorld.java

CMD ["java", "HelloWorld"]
