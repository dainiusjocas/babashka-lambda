FROM borkdude/babashka:0.0.78 as BABASHKA

FROM clojure:tools-deps-alpine as BUILDER
RUN apk add --no-cache zip
WORKDIR /var/task

COPY --from=BABASHKA /usr/local/bin/bb bb

ENV GITLIBS=".gitlibs/"
COPY lambda/bootstrap bootstrap

COPY deps.edn deps.edn

RUN clojure -Sdeps '{:mvn/local-repo "./.m2/repository"}' -Spath > cp
COPY src/ src/
COPY resources/ resources/

RUN ./bb -cp $(cat cp) -m lambda.core --uberscript core.clj

RUN zip -q -r function.zip bb bootstrap core.clj
