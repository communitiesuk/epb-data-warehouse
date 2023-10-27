FROM ruby:3.1.3

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

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -; \
    apt-get update -qq && apt-get install -y -qq --no-install-recommends nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app
RUN bundle install

RUN adduser --system --no-create-home nonroot
USER nonroot

ENTRYPOINT ["bundle", "exec", "rake"]

