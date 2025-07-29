# ---------- STAGE 1: Build Flutter Web ----------
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app
COPY . .

# Scarica le dipendenze
RUN flutter pub get

# Compila l'app per il web
RUN flutter build web

# ---------- STAGE 2: Serve con http-server ----------
FROM node:18-alpine

RUN npm install -g http-server

COPY --from=builder /app/build/web /web

EXPOSE 8080
CMD ["http-server", "/web", "-p", "8080"]
