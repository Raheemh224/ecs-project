# Stage 1: Build stage
FROM node:24.8-slim AS build 
WORKDIR /app
COPY package.json yarn.lock ./ 
RUN yarn install
COPY . .
RUN yarn build

# Stage 2: Production Stage

FROM node:24.8-slim 
WORKDIR /app
RUN yarn global add serve
# Create group and user
RUN groupadd appgroup && useradd -m -g appgroup appuser
USER appuser
COPY --from=build /app/build /app/build
EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]