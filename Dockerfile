# Use the official Node.js 18 Alpine image for a small footprint
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies strictly for production
RUN npm ci --only=production || npm install

# Copy the rest of the application files
COPY . .

# Expose port 80 (since we specified that in server.js)
EXPOSE 80

# Command to run the application
CMD [ "node", "server.js" ]
