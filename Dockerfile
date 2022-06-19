FROM kiesun/kieq_build:latest AS front_builder

WORKDIR /root

RUN git clone https://github.com/KieQ/bitsleep-demo-frontend.git

WORKDIR /root/bitsleep-demo-frontend

RUN sh script/build.sh

FROM golang:latest AS back_builder

WORKDIR /root

RUN git clone https://github.com/KieQ/bitsleep-demo-backend.git

WORKDIR /root/bitsleep-demo-backend

RUN sh script/build.sh

FROM nginx:latest

COPY --from=front_builder /root/bitsleep-demo-frontend/dist/ /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

COPY default.conf.template /etc/nginx/conf.d/default.conf.template

COPY --from=back_builder /root/bitsleep-demo-backend/demo /root

WORKDIR /root/

CMD /root/demo& /bin/bash -c "envsubst '\$PORT:\$BACKEND_PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'