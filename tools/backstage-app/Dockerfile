FROM node:20.18.0 as builder

WORKDIR /app

ADD ./packages/app/package.json package.json
RUN yarn install

FROM node:20.18.0

WORKDIR /app

COPY --from=builder /app ./

RUN npm i -g @backstage/cli@0.29.2

ADD ./app-config.yaml ./app-config.yaml
COPY ./packages/app/assets ./assets
COPY ./packages/app/public ./public
COPY ./packages/app/src ./src

EXPOSE 3000

ENTRYPOINT backstage-cli package start