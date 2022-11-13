(xbindkey-function '(b:7)
                   (let ((count 0))
                     (lambda ()
                       (set! count (+ count 1))
                       (if (> count 2)
                           (begin
                            (set! count 0)
                            (run-command "xdotool key 'Control_L+Next'"))))))
(xbindkey-function '(b:6)
                   (let ((count 0))
                     (lambda ()
                       (set! count (+ count 1))
                       (if (> count 2)
                           (begin
                            (set! count 0)
                            (run-command "xdotool key 'Control_L+Prior'"))))))

