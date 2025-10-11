FROM node:10

WORKDIR /usr/src/app
COPY package.json .
RUN npm install
COPY . .

# Runs as root by default (image user)
EXPOSE 3000
CMD ["npm", "start"]
