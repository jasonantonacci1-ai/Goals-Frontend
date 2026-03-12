FROM node:18-alpine as builder

WORKDIR /app

COPY package.json .

RUN rm -rf package-lock.json node_modules && npm install --legacy-peer-deps

COPY . .

EXPOSE 3000

RUN NODE_OPTIONS="--max-old-space-size=1024" npm run build

FROM nginx:alpine

COPY --from=builder /app/build  /usr/share/nginx/html

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
