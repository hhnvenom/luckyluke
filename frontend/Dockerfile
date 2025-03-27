FROM node:23-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all files
COPY . .

# Build the app
RUN npm run build

# Stage 2: Setup the production environment
FROM node:23-alpine

# Install serve to run the application
RUN npm install -g serve

# Set working directory
WORKDIR /app

# Copy built assets from the builder stage
COPY --from=builder /app/public ./public

# Expose the port the app runs on
EXPOSE 3000

# Command to run the app
CMD ["serve", "-s", "public", "-l", "3000"]
