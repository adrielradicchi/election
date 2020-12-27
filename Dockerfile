# Base image
FROM nginx

# Install dependencies 
# RUN apk update && apk add --update apache2-utils postgresql-dev
RUN apt-get update && apt-get -y install apache2-utils
# RUN mkdir /var/www/text-smasher && mkdir /var/www/text-smasher/log && touch /var/www/text-smasher/log/nginx.access.log
# Using argument for conditional setup in conf file  
ARG RAILS_ENV
ENV RAILS_ENV $RAILS_ENV

# establish where Nginx should look for files
ENV RAILS_ROOT /var/www/vote

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

# create log directory
RUN mkdir log

COPY ./vote $RAILS_ROOT

# RUN cd $RAILS_ROOT && rails db:migrate db:seed 

# copy over static assets
COPY ./vote/public public/

# Copy Nginx config template
COPY ./nginx.conf /tmp/docker.nginx

# substitute variable references in the Nginx config template for real values from the environment
# put the final config in its place
RUN envsubst '$RAILS_ROOT $RAILS_ENV' < /tmp/docker.nginx > /etc/nginx/conf.d/default.conf

# RUN ls / 
# RUN bundle exec rake db:drop db:create db:migrate db:seed 
RUN rm -rf /var/www/text-smasher
RUN mkdir /var/www/text-smasher && mkdir /var/www/text-smasher/log && touch /var/www/text-smasher/log/nginx.access.log
EXPOSE 80

# Use the "exec" form of CMD so Nginx shuts down gracefully on SIGTERM (i.e. `docker stop`)
CMD [ "nginx", "-g", "daemon off;" ]