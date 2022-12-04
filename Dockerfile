FROM node:16.18.0-alpine3.16 as builder

LABEL maintainer="jack.crosnierdebellaistre@kikotey.com"

ARG REACT_APP_BASE_URL
ENV REACT_APP_BASE_URL $REACT_APP_BASE_URL
RUN apk add --no-cache git

WORKDIR /app

RUN rm -Rf ./examples/classic-typescript/docs \
    ./examples/classic-typescript/blog \
    ./examples/classic-typescript/docusaurus.config.js \
    ./examples/classic-typescript/sidebars.js

COPY ./examples/classic-typescript/. ./
COPY ./markdowns/docs ./
COPY ./markdowns/blog ./
COPY ./configurations/. ./

RUN yarn install
RUN yarn run build


###
###
### FROM BUILDER
###
###
FROM nginx:alpine
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
ARG PROJECT_URL
ARG USER_EMAIL="jack.crosnierdebellaistre@kikotey.com"
ARG USER_NAME="Jack CROSNIER DE BELLAISTRE"
LABEL maintainer="${USER_NAME} <${USER_EMAIL}>" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url=$PROJECT_URL \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION
COPY --from=builder /app/build  /usr/share/nginx/html
COPY ./configurations/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
