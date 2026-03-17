FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY src ./src
COPY sql ./sql

ENV NODE_ENV=production
ENV PORT=3201

EXPOSE 3201

CMD ["npm", "start"]
