FROM ruby:2.7.1

WORKDIR /api
ENV RAILS_LOG_TO_STDOUT=true

ADD https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz /

# Install ffmpeg
RUN mkdir /ffmpeg && \
    tar -xJf /ffmpeg-release-amd64-static.tar.xz -C /ffmpeg --strip-components=1 && \
    cp /ffmpeg/ffmpeg /usr/local/bin/ && \
    rm -rf /ffmpeg*

COPY Gemfile* ./
RUN bundle install

COPY . .

CMD ["/bin/bash", "entrypoint.sh"]
