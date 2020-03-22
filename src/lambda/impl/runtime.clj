(ns lambda.impl.runtime
  (:require
    [babashka.curl :as curl]
    [cheshire.core :as json]
    [clojure.string :as str]))

(defn resp->map [resp]
  (let [lines (str/split resp #"\r\n")
        status (Integer/parseInt (second (str/split (first lines) #" ")))
        headers (reduce (fn [acc header-line]
                          (let [[k v] (str/split header-line #":" 2)]
                            (assoc acc (str/lower-case k) (str/trim v))))
                        {}
                        (remove str/blank? (drop-last (rest lines))))]
    {:body    (last lines)
     :status  status
     :headers headers}))

(defn- get-lambda-invocation-request [runtime-api]
  (resp->map
    (curl/request
      {:method   :get
       :url      (str "http://" runtime-api "/2018-06-01/runtime/invocation/next")
       :timeout  900000
       :raw-args ["-i"]})))

(defn- send-response [runtime-api lambda-runtime-aws-request-id response-body]
  (curl/request
    {:method  :post
     :url     (str "http://" runtime-api "/2018-06-01/runtime/invocation/" lambda-runtime-aws-request-id "/response")
     :body    response-body
     :headers {"Content-Type" "application/json"}}))

(defn- send-error [runtime-api lambda-runtime-aws-request-id error-body]
  (curl/request
    {:method  :post
     :url     (str "http://" runtime-api "/2018-06-01/runtime/invocation/" lambda-runtime-aws-request-id "/error")
     :body    error-body
     :headers {"Content-Type" "application/json"}}))

(defn- request->response [request-body handler-fn]
  (let [decoded-request (json/decode request-body true)]
    (json/encode (handler-fn decoded-request))))

(defn init [handler-fn]
  (let [runtime-api (System/getenv "AWS_LAMBDA_RUNTIME_API")]
    (loop [req (get-lambda-invocation-request runtime-api)]
      (let [lambda-runtime-aws-request-id (get (get req :headers) "lambda-runtime-aws-request-id")]
        (when-let [error (get req :error)]
          (send-error runtime-api lambda-runtime-aws-request-id (str error))
          (throw (Exception. (str error))))
        (try
          (send-response runtime-api
                         lambda-runtime-aws-request-id
                         (request->response (get req :body) handler-fn))
          (catch Exception e
            (send-error runtime-api lambda-runtime-aws-request-id (str e)))))
      (recur (get-lambda-invocation-request runtime-api)))))
