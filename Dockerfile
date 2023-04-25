FROM node:18-alpine3.17 as dev
WORKDIR /app
COPY package.json ./
RUN yarn install
CMD [ "yarn","start" ]

FROM node:18-alpine3.17 as dev-deps
WORKDIR /app
COPY package.json package.json
RUN yarn install --frozen-lockfile

FROM node:18-alpine3.17 as builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .
# RUN yarn test
RUN yarn build

FROM nginx:1.23.3 as prod
COPY --from=builder /app/dist/front/ /usr/share/nginx/html
COPY assets/ /usr/share/nginx/html/assets
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/conf.d
CMD [ "nginx","-g","daemon off;" ]