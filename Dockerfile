FROM ruby:3.1.3

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG=en_GB.UTF-8
ENV DATABASE_URL=postgresql://epb:SecretWarehousePassword@epb-data-warehouse-db/epb?pool=50
ENV EPB_API_URL=http://epb-register-api
ENV EPB_QUEUES_URI=redis://epb-data-warehouse-queues
ENV EPB_AUTH_CLIENT_ID=5e7b7607-971b-45a4-9155-cb4f6ea7e9f5
ENV EPB_AUTH_CLIENT_SECRET=data-warehouse-secret
ENV EPB_AUTH_SERVER=http://epb-auth-server/auth
ENV EPB_UNLEASH_URI=http://epb-feature-flag/api
ENV JWT_ISSUER=epb-auth-server
ENV JWT_SECRET=test-jwt-secret
ENV STAGE=development

COPY . /app
WORKDIR /app
RUN bundle install


ENTRYPOINT ["bundle", "exec", "ruby", "app.rb"]

