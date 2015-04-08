;;;; nebula-www.asd

(asdf:defsystem #:nebula-www
  :description "Describe nebula-www here"
  :author "Kyle Isom <kyle@metacircular.net>"
  :license "MIT License"
  :depends-on (#:cl-who
               #:log4cl
               #:flexi-streams
               #:restas
               #:st-json
               #:nebula)
  :serial t
  :components ((:file "package")
               (:file "nebula-www")))

