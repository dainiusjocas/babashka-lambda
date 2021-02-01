# NOTE: Use the same kind of base OS for both bb and tools-deps,
# one that is compatible with amazonlinux (v2)
FROM babashka/babashka:0.2.8 as BABASHKA

FROM clojure:tools-deps as BUILDER
RUN apt-get -y update && apt-get -y install zip
WORKDIR /var/task

COPY --from=BABASHKA /usr/local/bin/bb bb

ENV GITLIBS=".gitlibs/"
COPY lambda/bootstrap bootstrap

COPY deps.edn deps.edn

COPY src/ src/
COPY resources/ resources/

RUN clojure -Sdeps '{:mvn/local-repo "./.m2/repository"}' -Spath > cp
RUN ./bb -cp $(cat cp) -m lambda.core --uberscript core.clj
RUN zip -q -r function.zip bb bootstrap core.clj

# Or, e.g. if you also want to include a pod:
# RUN clojure -A:remove-clojure -Sdeps '{:mvn/local-repo "./.m2/repository"}' -Spath > cp
# RUN ./bb -cp $(cat cp) -m lambda.core --uberjar lambda.jar
# RUN zip -q -r function.zip bb bootstrap lambda.jar # + any pods you downloaded
