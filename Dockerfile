# ---------- BUILD STAGE ----------
FROM debian:bookworm AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        make git zlib1g-dev libssl-dev gperf cmake clang \
        libc++-dev libc++abi-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git

WORKDIR /build/telegram-bot-api/build

RUN CXXFLAGS="-stdlib=libc++" \
    CC=/usr/bin/clang \
    CXX=/usr/bin/clang++ \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX:PATH=.. .. && \
    cmake --build . --target install


# ---------- RUNTIME STAGE ----------
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    libssl3 zlib1g libc++1 libc++abi1 ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /build/telegram-bot-api/bin/telegram-bot-api /app/

EXPOSE 8081

CMD ["./telegram-bot-api", "--local"]