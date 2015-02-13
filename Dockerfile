FROM ruby:2.2.0-onbuild

CMD middleman build && tar -zcvf build.tar.gz build
