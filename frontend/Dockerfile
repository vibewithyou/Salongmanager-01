FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:$PATH"

# Enable Flutter web
RUN flutter config --enable-web

WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build web
RUN flutter build web --release

# Expose port
EXPOSE 3000

# Serve the app
CMD ["flutter", "run", "-d", "web-server", "--web-port", "3000", "--web-hostname", "0.0.0.0"]
