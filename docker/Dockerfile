# Stage 1: Build stage.
#        - alpine (stable)
#        - alpine:edge (latest and greatest)
FROM alpine as build-env

# Install dependencies.
RUN apk update                 \
 && apk add --no-cache         \
    bison                      \
    cmake                      \
    gcc                        \
    g++                        \
    gperf                      \
    make                       \
    musl-dev                   \
    perl                       \
    nettle-dev                 \
    argon2-dev                 \
    sqlite-dev                 \
    aspell-dev                 \
    pcre-dev                   \
    curl-dev                   \
    openssl-dev

# Setup build arguments.
ARG MAKE_JOBS=4

# Security: Create a passwd file with a nice, cozy user to run as.
RUN echo "nobody:x:65534:65534:nobody:/:/sbin/nologin" > /passwd \
    && echo "nobody:x:65534:" > /group                           \
    && chmod 644 /passwd                                         \
    && chmod 644 /group

# Copy files.
COPY CMakeLists.txt Minimal.db  /toaststunt_work/
COPY CMakeModules/              /toaststunt_work/CMakeModules/
COPY src/                       /toaststunt_work/src/

# Build the restart program and server with a release build and LTO.
WORKDIR /toaststunt_work/build

RUN gcc ../src/docker/docker_restart.c -Os -s -static -o restart \
    && cmake -DCMAKE_BUILD_TYPE=Release ../                      \
             -DENABLE_LTO=ON                                     \
    && make -j${MAKE_JOBS}                                       \
    && strip ./moo

# Extract the necessary libraries.
RUN mkdir -p ./lib && cd ./lib                                                   \
    && ldd ../moo | awk '{if ($3 != "not") print $3}' | xargs -I % cp % ./       \
    && musl_version=$(ls ld-musl*.so.1)                                          \
    && rm ./ld-musl*.so.1 && cp -P /usr/lib/libc.so ./${musl_version}            \
    && cd ../

# Create the final production directory.
RUN mkdir /toaststunt                                        \
    && chown 65534:65534 /toaststunt                         \
    && cp ./moo /toaststunt                                  \
    && cp ./restart /toaststunt                              \
    && cp ../Minimal.db /toaststunt                          \
    && mkdir -p /moo/executables /moo/files                  \
    && ln -s /moo/executables /toaststunt/executables        \
    && ln -s /moo/files /toaststunt/files                    \
    && mkdir -p /toaststunt/executables /toaststunt/files

##################################################################################

# Stage 2: Production stage.
FROM scratch

# Copy files to create 'nobody' user to run everything as.
COPY --from=build-env /passwd /group /etc/

# Copy executables.
COPY --from=build-env --chown=65534:65534 /toaststunt /toaststunt

# Copy libraries.
COPY --from=build-env /toaststunt_work/build/lib/ /usr/lib/
COPY --from=build-env /lib/ld-musl-*.so.1 /lib/
COPY --from=build-env /etc/ssl/certs /etc/ssl/certs

# Don't need root privileges, set user to nobody.
USER 65534:65534

# Expose default port 7777
EXPOSE 7777

# Define the expected volume.
VOLUME /moo

# Start in the correct directory.
WORKDIR /toaststunt

# Set some metadata.
LABEL maintainer="lisdude <lisdude@lisdude.com>"

# Run the server. Restart will pick up environment variables or default to Minimal.db.
ENTRYPOINT ["./restart"]
