# STAGE 1: Build the JAR (The "Workhorse")
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copy only the pom.xml first to cache dependencies (saves time)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the source code and build the package
COPY src ./src
RUN mvn clean package -DskipTests

# STAGE 2: Runtime (The "Minimal" Image)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Security: Upgrade existing Alpine packages
RUN apk update && apk upgrade --no-cache

# Copy only the built JAR from the first stage
COPY --from=build /app/target/*.jar app.jar

# Run as non-root user for security
USER 1000

EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]