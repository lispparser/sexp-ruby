;; -*- scheme -*-

(element (name "pingus-level")
  (use  "required")
  (type (mapping
         (children
          (element (name "version") (type (integer)))
          (element (name "head") 
            (type (mapping
                   (children
                    (element (name "levelname")        (type (string)))
                    (element (name "description")      (type (string)))
                    (element (name "author")           (type (string)))
                    (element (name "number-of-pingus") (type (integer)))
                    (element (name "number-to-save")   (type (integer)))
                    (element (name "levelsize")        (type (size)))
                    (element (name "time")             (type (integer)))
                    (element (name "difficulty")       (type (integer)))
                    (element (name "playable")         (type (integer)))
                    (element (name "comment")          (type (string)))
                    (element (name "music")            (type (string)))
                    (element (name "actions")
                      (type (mapping
                             (children
                              (element (name "basher")   (type (integer (min 1))) (use "optional"))
                              (element (name "blocker")  (type (integer (min 1))) (use "optional"))
                              (element (name "bomber")   (type (integer (min 1))) (use "optional"))
                              (element (name "digger")   (type (integer (min 1))) (use "optional"))
                              (element (name "bridger")  (type (integer (min 1))) (use "optional"))
                              (element (name "climber")  (type (integer (min 1))) (use "optional"))
                              (element (name "floater")  (type (integer (min 1))) (use "optional"))
                              (element (name "jumper")   (type (integer (min 1))) (use "optional"))
                              (element (name "miner")    (type (integer (min 1))) (use "optional"))
                              (element (name "slider")   (type (integer (min 1))) (use "optional"))

                              (element (name "boarder")   (type (integer (min 1))) (use "optional"))
                              (element (name "angel")   (type (integer (min 1))) (use "optional"))
                              (element (name "rocketlauncher")   (type (integer (min 1))) (use "optional"))
                              (element (name "superman")   (type (integer (min 1))) (use "optional"))
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
                               (element (name "release-rate") (type (integer)))))))

                     (element (name "surface-background")
                       (type (mapping
                              (children
                               (element (name "position") (type (vector2i)))
                               (element (name "surface")  (type (surface)))))))

                     (element (name "liquid")
                       (type (mapping
                              (children
                               (element (name "position") (type (vector2i)))
                               (element (name "surface")  (type (surface)))))))

                     (element (name "hotspot")
                       (type (mapping
                              (children
                               (element (name "position") (type (vector2i)))
                               (element (name "surface")  (type (surface)))))))


                     (element (name "exit")
                       (type (mapping
                              (children
                               (element (name "position") (type (vector2i)))
                               (element (name "surface")  (type (surface)))))))

                     (element (name "entrance")
                       (type (mapping
                              (children
                               (element (name "position") (type (vector2i)))))))

                     (element (name "spike")
                       (type (any)))

                     (element (name "snow-generator")
                       (type (any)))

                     (element (name "laser_exit")
                       (type (any)))

                     (element (name "fake_exit")
                       (type (any)))

                     (element (name "smasher")
                       (type (any)))

                     (element (name "guillotine")
                       (type (any)))

                     (element (name "conveyorbelt")
                       (type (any)))

                     (element (name "bumper")
                       (type (any)))

                     (element (name "hammer")
                       (type (any)))

                     (element (name "iceblock")
                       (type (any)))

                     (element (name "switchdoor")
                       (type (any)))

                     (element (name "solidcolor-background")
                       (type (any)))

                     (element (name "starfield-background")
                       (type (any)))

                     (element (name "thunderstorm-background")
                       (type (any)))

                     (element (name "infobox")
                       (type (any)))

                     (element (name "teleporter")
                       (type (any)))

                     (element (name "teleporter-target")
                       (type (any)))

                     (element (name "rain-generator")
                       (type (any)))
                     
                     ))))
          ))))

;; EOF ;;
