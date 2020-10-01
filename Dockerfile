FROM ppc64le/node:12.17 as build
ARG NPM_TOKEN
#COPY .npmrc .npmrc
#RUN npm config set registry http://10.144.16.161:8081/repository/ITD_NPM_GROUP/
RUN mkdir /app
# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH
ENV NODE_DEBUG node

# install and cache app dependencies
COPY package.json  /app/
#RUN npm login -registry http://10.144.16.161:8081/repository/ITD_NPM_GROUP/

#RUN npm install -g
# RUN npm install -g @angular/cli@7.3.9
# RUN npm uninstall -g @angular/cli@7
RUN npm install -g @angular/cli@7.3.9
RUN npm install
# add app
#COPY . /app
COPY . .
#COPY fo-util /app/node_modules

# generate build
#RUN npm run ng build -- --prod --base-href /
#RUN npm run build
#RUN npm run ng build -- --prod --output-path=dist
#RUN node --max_old_space_size=8048 node_modules/\@angular/cli/bin/ng build --verbose=false --progress=true --optimization=false --base-href=/cpcenv/foreturns/
#RUN node --max_old_space_size=16048 node_modules/\@angular/cli/bin/ng build --verbose=false --prod --progress=true --optimization=true --base-href=/foreturns/
#RUN node --max_old_space_size=16048 node_modules/\@angular/cli/bin/ng build --verbose=false --prod --progress=true --optimization=true -build-optimizer --extractCss=true --buildOptimizer=true --aot=true --base-href=/foreturns/
RUN node --max_old_space_size=8048 node_modules/\@angular/cli/bin/ng build --verbose=false --prod --progress=true --optimization=true --extractCss=true --buildOptimizer=true --aot=true --base-href=/foreturns/

#Push build artifacts to nexus repo
RUN export date=$(date +%d%m%y_%H%M%S); tar -cvzf foreturns_$date.tgz dist; curl -v -u 'admin:intense123' --upload-file /app/foreturns_$date.tgz http://10.255.0.51:8081/repository/rawrepo/


# base image
FROM ppc64le/nginx:latest
RUN apt-get update && apt-get -qq  install vim && apt-get -qq install net-tools
COPY default.conf /etc/nginx/conf.d/
# copy artifact build from the 'build environment'
COPY --from=build /app/dist /usr/share/nginx/html
# COPY ./default.conf /etc/nginx/conf.d/default.conf

# expose port 80
EXPOSE 80

# run nginx
CMD ["nginx", "-g", "daemon off;"]

# Run apt update && apt install -y tzdata

# Run unlink /etc/localtime

# Run ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

