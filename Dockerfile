FROM registry.access.redhat.com/ubi9/nodejs-20@sha256:938970e0012ddc784adda181ede5bc00a4dfda5e259ee4a57f67973720a565d1 as builder

WORKDIR  /opt/app-root/src
RUN npm install yarn --global

COPY @types @types
COPY public public
COPY src src
COPY package.json package.json
COPY tsconfig.json tsconfig.json
COPY webpack.config.js webpack.config.js
COPY webpack.prod.config.js webpack.prod.config.js 
COPY yarn.lock yarn.lock
COPY .swcrc .swcrc
COPY aliases.config.js aliases.config.js

RUN yarn install
RUN yarn build

FROM registry.access.redhat.com/ubi9/nginx-120@sha256:aea08753a83bc509c8abf72866a8a69ffcf824a640bd3c3257887fdd515b3aa3

COPY --from=builder /opt/app-root/src/dist/* /opt/app-root/src/

USER 0
# Disable IPv6 since it's not enabled on all systems
RUN sed -i '/\s*listen\s*\[::\]:8080 default_server;/d' /etc/nginx/nginx.conf
USER 1001

CMD ["nginx", "-g", "daemon off;"]
