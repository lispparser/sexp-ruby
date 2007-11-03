;; -*- scheme -*-

(element (name "pingus-level")
  (use  "required")
  (type (mapping
         (children
          (element (name "version") (type (int)))
          (element (name "head") 
            (type (mapping
                   (children
                    (element (name "levelname")        (type (string)))
                    (element (name "description")      (type (string)))
                    (element (name "author")           (type (string)))
                    (element (name "number-of-pingus") (type (int)))
                    (element (name "number-to-save")   (type (int)))
                    (element (name "time")             (type (int)))
                    (element (name "difficulty")       (type (int)))
                    (element (name "playable")         (type (int)))
                    (element (name "comment")          (type (string)))
                    (element (name "music")            (type (string)))
                    (element (name "actions")
                      (type (mapping
                             (children
                              (element (name "basher")   (type (int (min 1))))
                              (element (name "blocker")  (type (int (min 1))))
                              (element (name "bomber")   (type (int (min 1))))
                              (element (name "bridger")  (type (int (min 1))))
                              (element (name "climber")  (type (int (min 1))))
                              (element (name "jumper")   (type (int (min 1))))
                              ))))
                    ))))
          (element (name "objects")
            (type (sequence
                    (children
                     (element (name "groundpiece")
                       (type (mapping
                              (children
                               (element (name "position") (type (vector2i)))
                               (element (name "surface")  (type (surface)))))))

                     (element (name "exit")
                       (type (mapping
                              (children
                               (element (name "position") (type (vector2i)))
                               (element (name "surface")  (type (surface)))
                               (element (name "release-rate") (type (int)))))))
                     ))))
          ))))

;; EOF ;;
