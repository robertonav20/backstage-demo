# Stage 2
FROM node:18-bullseye AS builder
WORKDIR /app
COPY package*.json .
COPY package*.lock .
RUN npm install
COPY . .
RUN npm run build

# Stage 2
FROM nginx:1.19.0
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/build .
ENTRYPOINT ["nginx", "-g", "daemon off;"]