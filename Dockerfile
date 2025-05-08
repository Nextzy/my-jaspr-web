# Use the official dart docker image as our build image.
FROM ghcr.io/cirruslabs/flutter:stable as build

# Activate the jaspr cli.
RUN dart pub global activate jaspr_cli

WORKDIR /app
# Copy all files into the current image.
COPY . .

# Resolve app dependencies.
RUN rm -f pubspec_overrides.yaml
RUN dart pub get

# Build project
RUN dart pub global run jaspr_cli:jaspr build --verbose

# This image is additionally needed for the dart runtime libs.
FROM dart:stable as dart

# Use a new empty docker image, this will be the final container image.
FROM scratch

# Copy all the needed runtime libraries for dart.
COPY --from=dart /runtime/ /
# Copy the build outputs for your site.
COPY --from=build /app/build/jaspr/ /app/

WORKDIR /app

# Start the server.
EXPOSE 8080
CMD ["./app"]