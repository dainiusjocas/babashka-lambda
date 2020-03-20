(ns lambda.core
  (:require
    [lambda.impl.runtime :as runtime]))

(defn my-assoc [m k v]
  (assoc m k v))

(defn -main [& _]
  (let [k :test
        v "test"
        ; input to handler-fn is a parsed request body
        handler-fn (fn [request] (my-assoc request k v))]
    (runtime/init handler-fn)))
