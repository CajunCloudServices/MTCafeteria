FROM node:22-alpine

WORKDIR /app

COPY web/package*.json ./
RUN npm ci --omit=dev

COPY web ./

COPY public ./public

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["npm", "start"]
